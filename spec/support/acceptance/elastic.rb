# frozen_string_literal: true

require 'securerandom'
require 'rspec/retry'

require 'simp/beaker_helpers'
include Simp::BeakerHelpers # rubocop:disable Style/MixinUsage

require_relative '../../spec_helper_tls'
require_relative '../../spec_utilities'
require_relative '../../../lib/puppet_x/elastic/deep_to_i'
require_relative '../../../lib/puppet_x/elastic/deep_to_s'

# def f
#   RSpec.configuration.fact
# end

# FIXME: This value should better not be hardcoded
ENV['ELASTICSEARCH_VERSION'] = '7.10.1'
ENV.delete('BEAKER_debug')

run_puppet_install_helper('agent') unless ENV['BEAKER_provision'] == 'no'

RSpec.configure do |c|
  # General-purpose spec-global variables
  c.add_setting :v, default: {}

  # Puppet debug logging
  v[:puppet_debug] = ENV['BEAKER_debug'] ? true : false

  unless ENV['snapshot_version'].nil?
    v[:snapshot_version] = ENV['snapshot_version']
    v[:is_snapshot] = ENV['SNAPSHOT_TEST'] == 'true'
  end

  unless ENV['ELASTICSEARCH_VERSION'].nil? && v[:snapshot_version].nil?
    v[:elasticsearch_full_version] = ENV['ELASTICSEARCH_VERSION'] || v[:snapshot_version]
    v[:elasticsearch_major_version] = v[:elasticsearch_full_version].split('.').first.to_i
    v[:elasticsearch_package] = {}
    v[:template] = if v[:elasticsearch_major_version] == 6
                     JSON.parse(File.read('spec/fixtures/templates/6.x.json'))
                   elsif v[:elasticsearch_major_version] >= 8
                     JSON.parse(File.read('spec/fixtures/templates/post_8.0.json'))
                   else
                     JSON.parse(File.read('spec/fixtures/templates/7.x.json'))
                   end
    v[:template] = Puppet_X::Elastic.deep_to_i(Puppet_X::Elastic.deep_to_s(v[:template]))
    v[:pipeline] = JSON.parse(File.read('spec/fixtures/pipelines/example.json'))
  end

  v[:elasticsearch_plugins] = Dir[
    artifact("*#{v[:elasticsearch_full_version]}.zip", ['plugins'])
  ].map do |plugin|
    plugin_filename = File.basename(plugin)
    plugin_name = plugin_filename.match(%r{^(?<name>.+)-#{v[:elasticsearch_full_version]}.zip})[:name]
    [
      plugin_name,
      {
        path: plugin,
        url: derive_plugin_urls_for(v[:elasticsearch_full_version], [plugin_name]).keys.first,
      },
    ]
  end.to_h

  v[:oss] = !ENV['OSS_PACKAGE'].nil? and ENV['OSS_PACKAGE'] == 'true'
  v[:cluster_name] = SecureRandom.hex(10)

  # rspec-retry
  c.display_try_failure_messages = true
  c.default_sleep_interval = 10
  # General-case retry keyword for unstable tests
  c.around :each, :with_retries do |example|
    example.run_with_retry retry: 10
  end

  # Helper hook for module cleanup
  c.after :context, :with_cleanup do
    apply_manifest <<-MANIFEST
      class { 'elasticsearch':
        ensure      => 'absent',
        manage_repo => true,
        oss         => #{v[:oss]},
      }
      file { '/usr/share/elasticsearch/plugin':
        ensure  => 'absent',
        force   => true,
        recurse => true,
        require => Class['elasticsearch'],
      }
    MANIFEST
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
    if ENV['CI']
      Vault.auth.approle(ENV['VAULT_APPROLE_ROLE_ID'], ENV['VAULT_APPROLE_SECRET_ID'])
    else
      Vault.auth.token(ENV['VAULT_TOKEN'])
    end
    licenses = Vault.with_retries(Vault::HTTPConnectionError) do
      Vault.logical.read(ENV['VAULT_PATH'])
    end.data

    raise 'No license found!' unless licenses

    # license = case v[:elasticsearch_major_version]
    #           when 6
    #             licenses[:v5]
    #           else
    #             licenses[:v7]
    #           end
    license = licenses[:v7]
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
  # # Set the host to 'aio' in order to adopt the puppet-agent style of
  # # installation, and configure paths/etc.
  # host[:type] = 'aio'
  # configure_defaults_on host, 'aio'

  if fact('os.family') == 'Suse'
    install_package host,
                    '--force-resolution augeas-devel libxml2-devel ruby-devel'
    on host, 'gem install ruby-augeas --no-ri --no-rdoc'
  end

  v[:ext] = case fact('os.family')
            when 'Debian'
              'deb'
            else
              'rpm'
            end

  v[:elasticsearch_package]&.merge!(
    derive_full_package_url(
      v[:elasticsearch_full_version], [v[:ext]]
    ).flat_map do |url, filename|
      [[:url, url], [:filename, filename], [:path, artifact(filename)]]
    end.to_h
  )
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
    fetch_archives(derive_artifact_urls_for(ENV['ELASTICSEARCH_VERSION']))

    # Use the Java class once before the suite of tests
    unless shell('command -v java', accept_all_exit_codes: true).exit_code.zero?
      java = case fact('os.name')
             when 'OpenSuSE'
               'package => "java-1_8_0-openjdk-headless",'
             else
               ''
             end

      apply_manifest <<-MANIFEST
        class { "java" :
          distribution => "jdk",
          #{java}
        }
      MANIFEST
    end
  end
end
# # Java 8 is only easy to manage on recent distros
# def v5x_capable?
#   (fact('os.family') == 'RedHat' and \
#     not (fact('os.name') == 'OracleLinux' and \
#     f['os']['release']['major'] == '6')) or \
#     f.dig 'os', 'distro', 'codename' == 'xenial'
# end
