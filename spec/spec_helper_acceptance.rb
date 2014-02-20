require 'beaker-rspec'
require 'pry'

hosts.each do |host|
  # Install Puppet
  if host.is_pe?
      install_pe
  else
    puppetversion = ENV['VM_PUPPET_VERSION']
    install_package host, 'rubygems'
    on host, "gem install puppet --no-ri --no-rdoc --version '~> #{puppetversion}'"
    on host, "mkdir -p #{host['distmoduledir']}"
  end
end

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    puppet_module_install(:source => proj_root, :module_name => 'elasticsearch')
    hosts.each do |host|
      if !host.is_pe?
        on host, puppet('module','install','puppetlabs-stdlib', '-v 3.2.0'), { :acceptable_exit_codes => [0,1] }
      end
      if fact('osfamily') == 'Debian'
        on host, puppet('module','install','puppetlabs-apt'), { :acceptable_exit_codes => [0,1] }
      end
    end
  end
end
