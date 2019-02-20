require 'beaker-rspec'
require 'securerandom'
require 'thread'
require 'infrataster/rspec'
require 'rspec/retry'
require 'vault'

require_relative 'spec_helper_tls'
require_relative 'spec_utilities'
require_relative '../lib/puppet_x/elastic/deep_to_i'
require_relative '../lib/puppet_x/elastic/deep_to_s'

def f
  RSpec.configuration.fact
end

RSpec.configure do |c|
  # General-purpose spec-global variables
  c.add_setting :v, :default => {}

  unless ENV['snapshot_version'].nil?
    v[:snapshot_version] = ENV['snapshot_version']
    v[:is_snapshot] = ENV['SNAPSHOT_TEST'] == 'true'
  end

  unless ENV['ELASTICSEARCH_VERSION'].nil? and v[:snapshot_version].nil?
    v[:elasticsearch_full_version] = ENV['ELASTICSEARCH_VERSION'] || v[:snapshot_version]
    v[:elasticsearch_major_version] = v[:elasticsearch_full_version].split('.').first.to_i
    v[:elasticsearch_package] = {}
    v[:template] = if v[:elasticsearch_major_version] < 6
                     JSON.load(File.new('spec/fixtures/templates/pre_6.0.json'))
                   elsif v[:elasticsearch_major_version] >= 8
                     JSON.load(File.new('spec/fixtures/templates/post_8.0.json'))
                   else
                     JSON.load(File.new('spec/fixtures/templates/post_6.0.json'))
                   end
    v[:template] = Puppet_X::Elastic.deep_to_i(Puppet_X::Elastic.deep_to_s(v[:template]))
    v[:pipeline] = JSON.load(File.new('spec/fixtures/pipelines/example.json'))

    v[:elasticsearch_plugins] = Dir[
      artifact("*#{v[:elasticsearch_full_version]}.zip", ['plugins'])
    ].map do |plugin|
      plugin_filename = File.basename(plugin)
      plugin_name = plugin_filename.match(/^(?<name>.+)-#{v[:elasticsearch_full_version]}.zip/)[:name]
      [
        plugin_name,
        {
          :path => plugin,
          :url => derive_plugin_urls_for(v[:elasticsearch_full_version], [plugin_name]).keys.first
        }
      ]
    end.to_h
  end

  v[:oss] = (not ENV['OSS_PACKAGE'].nil?) and ENV['OSS_PACKAGE'] == 'true'
  v[:cluster_name] = SecureRandom.hex(10)

  # rspec-retry
  c.display_try_failure_messages = true
  c.default_sleep_interval = 5
  # General-case retry keyword for unstable tests
  c.around :each, :with_retries do |example|
    example.run_with_retry retry: 4
  end
  # More forgiving retry config for really flaky tests
  c.around :each, :with_generous_retries do |example|
    example.run_with_retry retry: 10
  end

  # Helper hook for module cleanup
  c.after :context, :with_cleanup do
    apply_manifest <<-EOS
      class { 'elasticsearch':
        ensure      => 'absent',
        manage_repo => true,
        oss         => #{v[:oss]},
      }
      elasticsearch::instance { 'es-01': ensure => 'absent' }

      file { '/usr/share/elasticsearch/plugin':
        ensure  => 'absent',
        force   => true,
        recurse => true,
        require => Class['elasticsearch'],
      }
    EOS
  end

  c.before :context, :with_certificates do
    @keystore_password = SecureRandom.hex
    @role = [*('a'..'z')].sample(8).join

    # Setup TLS cert placement
    @tls = gen_certs(2, '/tmp')

    create_remote_file hosts, @tls[:ca][:cert][:path], @tls[:ca][:cert][:pem]
    @tls[:clients].each do |node|
      node.each do |_type, params|
        create_remote_file hosts, params[:path], params[:pem]
      end
    end
  end

  c.before :context, :with_license do
    Vault.address = ENV['VAULT_ADDR']
    Vault.auth.approle ENV['VAULT_APPROLE_ROLE_ID'], ENV['VAULT_APPROLE_SECRET_ID']
    licenses = Vault.with_retries(Vault::HTTPConnectionError) do
      Vault.logical.read(ENV['VAULT_PATH'])
    end.data

    raise 'No license found!' unless licenses

    license = case v[:elasticsearch_major_version]
              when 2
                licenses[:v2]
              else
                licenses[:v5]
              end
    create_remote_file hosts, '/tmp/license.json', license
    v[:elasticsearch_license_path] = '/tmp/license.json'
  end

  c.after :context, :then_purge do
    shell 'rm -rf {/usr/share,/etc,/var/lib}/elasticsearch*'
  end

  c.before :context, :first_purge do
    shell 'rm -rf {/usr/share,/etc,/var/lib}/elasticsearch*'
  end

  # Provide a hook filter to spit out some ES logs if the example fails.
  c.after(:example, :logs_on_failure) do |example|
    if example.exception
      hosts.each do |host|
        on host, "find / -name '#{v[:cluster_name]}.log' | xargs cat || true" do |result|
          puts result.formatted_output
        end
      end
    end
  end
end

files_dir = ENV['files_dir'] || './spec/fixtures/artifacts'

# General bootstrapping steps for each host
hosts.each do |host|
  # Set the host to 'aio' in order to adopt the puppet-agent style of
  # installation, and configure paths/etc.
  host[:type] = 'aio'
  configure_defaults_on host, 'aio'

  # Install Puppet
  #
  # We spawn a thread to print dots periodically while installing puppet to
  # avoid inactivity timeouts in Travis. Don't judge me.
  progress = Thread.new do
    print 'Installing puppet..'
    print '.' while sleep 5
  end

  case host.name
  when /debian-9/
    # A few special cases need to be installed from gems (if the distro is
    # very new and has no puppet repo package or has no upstream packages).
    install_puppet_from_gem(
      host,
      version: Gem.loaded_specs['puppet'].version
    )
  else
    # Otherwise, just use the all-in-one agent package.
    install_puppet_agent_on(
      host,
      puppet_agent_version: to_agent_version(Gem.loaded_specs['puppet'].version)
    )
  end
  # Quit the print thread and include some debugging.
  progress.exit
  puts "done. Installed version #{shell('puppet --version').output}"

  RSpec.configure do |c|
    c.add_setting :fact, :default => JSON.parse(fact('', '-j'))
  end

  if f['os']['family'] == 'Suse'
    install_package host,
                    '--force-resolution augeas-devel libxml2-devel ruby-devel'
    on host, 'gem install ruby-augeas --no-ri --no-rdoc'
  end

  v[:ext] = case f['os']['family']
            when 'Debian'
              'deb'
            else
              'rpm'
            end

  if v[:elasticsearch_package]
    v[:elasticsearch_package].merge!(
      derive_full_package_url(
        v[:elasticsearch_full_version], [v[:ext]]
      ).flat_map do |url, filename|
        [[:url, url], [:filename, filename], [:path, artifact(filename)]]
      end.to_h
    )
  end

  Infrataster::Server.define(:docker) do |server|
    server.address = host[:ip]
    server.ssh = host[:ssh].tap { |s| s.delete :forward_agent }
  end
  Infrataster::Server.define(:container) do |server|
    server.address = host[:vm_ip] # this gets ignored anyway
    server.from = :docker
  end
end

RSpec.configure do |c|
  if v[:is_snapshot]
    c.before :suite do
      scp_to default,
             "#{files_dir}/elasticsearch-snapshot.#{v[:ext]}",
             "/tmp/elasticsearch-snapshot.#{v[:ext]}"
      v[:snapshot_package] = "file:/tmp/elasticsearch-snapshot.#{v[:ext]}"
    end
  end

  c.before :suite do
    # Install module and dependencies
    install_dev_puppet_module :ignore_list => [
      'junit'
    ] + Beaker::DSL::InstallUtils::ModuleUtils::PUPPET_MODULE_INSTALL_IGNORE

    hosts.each do |host|
      modules = %w[archive datacat java java_ks stdlib elastic_stack]

      dist_module = {
        'Debian' => ['apt'],
        'Suse'   => ['zypprepo'],
        'RedHat' => ['concat']
      }[f['os']['family']]

      modules += dist_module unless dist_module.nil?

      modules.each do |mod|
        copy_module_to(
          host,
          :module_name => mod,
          :source      => "spec/fixtures/modules/#{mod}"
        )
      end

      on(host, 'mkdir -p etc/puppet/modules/another/files/')

      # Apt doesn't update package caches sometimes, ensure we're caught up.
      shell 'apt-get update' if f['os']['family'] == 'Debian'
    end

    # Use the Java class once before the suite of tests
    unless shell('command -v java', :accept_all_exit_codes => true).exit_code.zero?
      java = case f['os']['name']
             when 'OpenSuSE'
               'package => "java-1_8_0-openjdk-headless",'
             else
               ''
             end

      apply_manifest <<-MANIFEST
        class { "java" :
          distribution => "jre",
          #{java}
        }
      MANIFEST
    end
  end
end

# Java 8 is only easy to manage on recent distros
def v5x_capable?
  (f['os']['family'] == 'RedHat' and \
    not (f['os']['name'] == 'OracleLinux' and \
    f['os']['release']['major'] == '6')) or \
    f.dig 'os', 'distro', 'codename' == 'xenial'
end
