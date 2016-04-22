require 'beaker-rspec'
require 'pry'
require 'securerandom'
require 'infrataster/rspec'
require_relative 'spec_acceptance_integration'
require_relative 'spec_helper_tls'

def test_settings
  RSpec.configuration.test_settings
end

RSpec.configure do |c|
  c.add_setting :test_settings, :default => {}
end

files_dir = ENV['files_dir'] || './spec/fixtures/artifacts'

hosts.each do |host|

  # Install Puppet
  if host.is_pe?
    install_pe
  else
    install_puppet_on host, :default_action => 'gem_install'

    if fact('osfamily') == 'Suse'
      install_package host, 'augeas-devel libxml2-devel'
      install_package host, '-t pattern devel_ruby'
      on host, "gem install ruby-augeas --no-ri --no-rdoc"
    end

    if host[:type] == 'aio'
      on host, "mkdir -p /var/log/puppetlabs/puppet"
    end
  end

  if ENV['ES_VERSION']

    case fact('osfamily')
      when 'RedHat'
        if ENV['ES_VERSION'][0,1] == '1'
          ext='noarch.rpm'
        else
          ext='rpm'
        end
      when 'Debian'
        ext='deb'
      when  'Suse'
        ext='rpm'
    end

    url = get_url
    RSpec.configuration.test_settings['snapshot_package'] = url.gsub('$EXT$', ext)
  else

    case fact('osfamily')
      when 'RedHat'
        package_name = 'elasticsearch-1.3.1.noarch.rpm'
      when 'Debian'
        case fact('lsbmajdistrelease')
          when '6'
            package_name = 'elasticsearch-1.1.0.deb'
          else
            package_name = 'elasticsearch-1.3.1.deb'
        end
      when 'Suse'
        case fact('operatingsystem')
          when 'OpenSuSE'
            package_name = 'elasticsearch-1.3.1.noarch.rpm'
        end
    end

    snapshot_package = {
        :src => "#{files_dir}/#{package_name}",
        :dst => "/tmp/#{package_name}"
    }

    scp_to(host, snapshot_package[:src], snapshot_package[:dst])
    scp_to(host, "#{files_dir}/elasticsearch-bigdesk.zip", "/tmp/elasticsearch-bigdesk.zip")
    scp_to(host, "#{files_dir}/elasticsearch-kopf.zip", "/tmp/elasticsearch-kopf.zip")

    RSpec.configuration.test_settings['snapshot_package'] = "file:#{snapshot_package[:dst]}"

  end

  Infrataster::Server.define(:proxy) do |server|
    server.address = host[:ip]
    server.ssh = host[:ssh]
  end
  Infrataster::Server.define(:container) do |server|
    server.address = '127.0.0.1'
    server.from = :proxy
  end
end

RSpec.configure do |c|

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do

    # Install module and dependencies
    install_dev_puppet_module :ignore_list => [
      'junit'
    ] + Beaker::DSL::InstallUtils::ModuleUtils::PUPPET_MODULE_INSTALL_IGNORE

    hosts.each do |host|

      copy_hiera_data_to(host, 'spec/fixtures/hiera/hieradata/')

      modules = ['stdlib', 'java', 'datacat']

      dist_module = {
        'Debian' => 'apt',
        'Suse'   => 'zypprepo',
        'RedHat' => 'yum',
      }[fact('osfamily')]

      modules << dist_module if not dist_module.nil?

      modules.each do |mod|
        copy_module_to host, {
          :module_name => mod,
          :source      => "spec/fixtures/modules/#{mod}"
        }
      end

      if host.is_pe?
        on(host, 'sed -i -e "s/PATH=PATH:\/opt\/puppet\/bin:/PATH=PATH:/" ~/.ssh/environment')
      end

      on(host, 'mkdir -p etc/puppet/modules/another/files/')

    end
  end

  c.after :suite do
    if ENV['ES_VERSION']
      hosts.each do |host|
        timestamp = Time.now
        log_dir = File.join('./spec/logs', timestamp.strftime("%F_%H_%M_%S"))
        FileUtils.mkdir_p(log_dir) unless File.directory?(log_dir)
        scp_from(host, '/var/log/elasticsearch', log_dir)
      end
    end
  end

end

require_relative 'spec_acceptance_common'
