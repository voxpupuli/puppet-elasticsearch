class Puppet::Provider::ElasticUserCommand < Puppet::Provider

  attr_accessor :homedir

  def self.homedir
    @homedir ||= case Facter.value('osfamily')
                 when 'OpenBSD'
                   '/usr/local/elasticsearch'
                 else
                   '/usr/share/elasticsearch'
                 end
  end

  def self.command_with_path(args)
    users_cli(args.is_a?(Array) ? args : [args])
  end

  def self.fetch_users
    begin
      output = command_with_path('list')
    rescue Puppet::ExecutionFailure => e
      debug("#fetch_users had an error: #{e.inspect}")
      return nil
    end

    debug("Raw command output: #{output}")
    output.split("\n").select { |u|
      # Keep only expected "user : role1,role2" formatted lines
      u[/^[^:]+:\s+\S+$/]
    }.map { |u|
      # Break into ["user ", " role1,role2"]
      u.split(':').first.strip
    }.map do |user|
      {
        :name => user,
        :ensure => :present,
        :provider => name,
      }
    end
  end

  def self.instances
    fetch_users.map do |user|
      new user
    end
  end

  def self.prefetch(resources)
    instances.each do |prov|
      if resource = resources[prov.name]
        resource.provider = prov
      end
    end
  end

  def initialize(value={})
    super(value)
    @property_flush = {}
  end

  def flush
    arguments = []

    case @property_flush[:ensure]
    when :absent
      arguments << 'userdel'
      arguments << resource[:name]
    else
      arguments << 'useradd'
      arguments << resource[:name]
      arguments << '-p' << resource[:password]
    end

    self.class.command_with_path(arguments)
    @property_hash = self.class.fetch_users.detect do |u|
      u[:name] == resource[:name]
    end
  end

  def create
    @property_flush[:ensure] = :present
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def destroy
    @property_flush[:ensure] = :absent
  end

  def passwd
    self.class.command_with_path([
      'passwd',
      resource[:name],
      '-p', resource[:password]
    ])
  end
end
