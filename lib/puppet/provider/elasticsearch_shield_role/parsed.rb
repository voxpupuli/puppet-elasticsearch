require 'puppet/provider/parsedfile'
roles = '/etc/elasticsearch/shield/roles.yml'

Puppet::Type.type(:elasticsearch_shield_role).provide(
  :parsed,
  :parent => Puppet::Provider::ParsedFile,
  :default_target => roles,
  :filetype => :flat,
) do
  desc "Provider for Shield file (esusers) user resources."

  def self.parse text
    yaml = YAML.load text
    if yaml
      yaml.map do |role, privileges|
        {
          :name => role,
          :ensure => :present,
          :privileges => privileges,
        }
      end
    else
      []
    end
  end

  def self.to_file records
    records.map do |record|
      # Convert top-level symbols to strings
      Hash[record.map { |k, v| [k.to_s, v] }]
    end.inject({}) do |hash, record|
      # Flatten array of hashes into single hash
      hash.merge({ record['name'] => record.delete('privileges') })
    end.to_yaml.gsub(/^\s{2}/, '') << "\n"
  end

  def self.skip_record? record
    false
  end
end
