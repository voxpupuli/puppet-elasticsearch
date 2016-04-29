Puppet::Type.type(:elasticsearch_shield_user).provide(:esusers) do
  desc "Provider for Shield file (esusers) user resources."

  mk_resource_methods

  os = Facter.value('osfamily')
  if os == 'OpenBSD'
    @homedir = '/usr/local/elasticsearch'
  else
    @homedir = '/usr/share/elasticsearch'
  end

  commands :esusers => "#{@homedir}/bin/shield/esusers"
  commands :es => "#{@homedir}/bin/elasticsearch"

  def self.esusers_with_path args
    args = [args] unless args.is_a? Array
    esusers(["--default.path.conf=#{@homedir}"] + args)
  end

  def self.users
    begin
      output = esusers_with_path('list')
    rescue Puppet::ExecutionFailure => e
      debug("#users had an error: #{e.inspect}")
      return nil
    end

    debug("Raw `esusers list` output: #{output}")
    output.split("\n").select { |u|
      # Keep only expected "user : role1,role2" formatted lines
      u[/^[^:]+:\s+\S+$/]
    }.map { |u|
      # Break into ["user ", " role1,role2"]
      u.split(':')
    }.map do |user|
      user.map(&:strip!)
      username, roles = user
      roles.delete!('-')
      roles.delete!('*')
      {
        :name => username,
        :ensure => :present,
        :provider => :esusers,
        :roles => roles.split(',')
      }
    end
  end

  def self.instances
    users.map do |user|
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

  def roles=(value)
    @property_flush[:roles] = value
  end

  def flush
    case @property_flush[:ensure]
    when :absent
      self.class.esusers_with_path(['userdel', resource[:name]])

    else
      arguments = []

      if @property_hash[:ensure] == :present
        # User exists; modifying roles
        arguments << 'roles' << resource[:name]
        remove_roles = @property_hash[:roles] - @property_flush[:roles]
        add_roles = @property_flush[:roles] - @property_hash[:roles]
        [['a', add_roles], ['r', remove_roles]].each do |flag, roles|
          arguments << "-#{flag}" << roles.join(',') unless roles.empty?
        end
      else
        # User needs to be created /and/ modified
        arguments << 'useradd'
        arguments << resource[:name]
        arguments << '-p' << resource[:password]
        if resource[:roles]
          arguments << '-r' << resource[:roles].join(',')
        end
      end

      self.class.esusers_with_path(arguments)
    end

    @property_hash = self.class.users.detect { |u| u[:name] == resource[:name] }
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
    self.class.esusers_with_path([
      'passwd',
      resource[:name],
      '-p', resource[:password]
    ])
  end
end
