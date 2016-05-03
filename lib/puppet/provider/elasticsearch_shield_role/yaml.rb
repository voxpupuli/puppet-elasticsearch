Puppet::Type.type(:elasticsearch_shield_role).provide(:yaml) do
  desc "Provider for Shield role privileges and mappings."

  mk_resource_methods

  def self.home_path
    case Facter.value('osfamily')
    when 'OpenBSD'
      '/usr/local'
    else
      '/usr/share'
    end
  end

  def self.roles
    "#{home_path}/elasticsearch/shield/roles.yml"
  end
  def self.mappings
    "#{home_path}/elasticsearch/shield/role_mapping.yml"
  end

  confine :exists => roles
  confine :exists => mappings

  def self.instances
    {:privileges => roles, :mappings => mappings}.map do |type, file|
      if yaml = YAML.load_file(file)
        yaml.map do |role, metadata|
          {
            role => {
              :name => role,
              :ensure => :present,
              :provider => :yaml,
              type => metadata
            }
          }
        end
      else
        {}
      end
    end.flatten.inject({}) do |hash, resource|
      hash.merge(resource) do |_, old, n|
        old.merge n
      end
    end.values.map do |resource|
      new resource
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

  def mappings=(value)
    @property_flush[:mappings] = value
  end

  def privileges=(value)
    @property_flush[:privileges] = value
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
end
