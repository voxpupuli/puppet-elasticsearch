require 'puppet/provider/parsedfile'

case Facter.value('osfamily')
when 'OpenBSD'
  roles = '/usr/local/elasticsearch/shield/roles.yml'
else
  roles = '/usr/share/elasticsearch/shield/roles.yml'
end

Puppet::Type.type(:elasticsearch_shield_role).provide(
  :parsed,
  :parent => Puppet::Provider::ParsedFile,
  :default_target => roles,
  :filetype => :flat
) do
  desc "Provider for Shield file (esusers) role resources."

  # This path needs to be defined in the provider to be accessible later to
  # append to the targets list.
  def self.role_mapping
    case Facter.value('osfamily')
    when 'OpenBSD'
      '/usr/local/elasticsearch/shield/role_mapping.yml'
    else
      '/usr/share/elasticsearch/shield/role_mapping.yml'
    end
  end

  # Override parse rather than record_line to consume the entirety of the file
  # as straightforward yaml.
  def self.parse text
    yaml = YAML.load text
    if yaml
      yaml.map do |role, metadata|
        # Return the resource in either the privileges form (hash derived
        # from roles.yml) or mappings list (from role_mapping.yml)
        if metadata.is_a? Array
          {
            :name => role,
            :mapping => metadata
          }
        else
          {
            :name => role,
            :privileges => metadata
          }
        end
      end
    else
      []
    end
  end

  # Merge the privileges and mappings for prefetched roles.
  def self.instances
    targets.collect do |target|
      # Parse both role yaml source files.
      prefetch_target target
    end.flatten.group_by do |record|
      # Gather all hashes in the array by role name.
      record[:name]
    end.map do |role, metadata|
      # Define an empty role hash, then merge with any parsed role metadata.
      {
        :name => role,
        :privileges => {},
        :mapping => [],
      }.merge(
        # Get rid of the name, leave only privileges/ensure/other properties.
        metadata.map do |meta|
          meta.delete(:name)
          meta
        # Gather up extra properties.
        end.inject({:target => []}) do |r, e|
          if t = e.delete(:target)
            r[:target] << t
          end
          r.merge(e)
        end
      )
    end.collect do |record|
      debug record.inspect
      new record
    end
  end

  def self.target_records(target)
    @records.find_all do |record|
      record[:target].include? target
    end.map do |record|
      if target == role_mapping
        record.merge({:metadata => record.delete(:mapping)})
      else
        record.merge({:metadata => record.delete(:privileges)})
      end
    end
  end

  def self.to_file records
    records.map do |record|
      # Convert top-level symbols to strings
      Hash[record.map { |k, v| [k.to_s, v] }]
    end.inject({}) do |hash, record|
      # Flatten array of hashes into single hash
      hash.merge({ record['name'] => record.delete('metadata') })
    end.to_yaml.gsub(/^\s{2}/, '') << "\n"
  end

  def self.skip_record? record ; false ; end

  # Add the role mapping target for processing
  def self.targets(resources = nil)
    targets = super(resources)
    targets << role_mapping
    targets
  end
end
