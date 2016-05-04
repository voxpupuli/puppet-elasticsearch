require 'puppet/provider/parsedfile'

class Puppet::Provider::ElasticYaml < Puppet::Provider::ParsedFile

  class << self
    attr_accessor :metadata
  end

  def self.parse text
    yaml = YAML.load text
    if yaml
      yaml.map do |key, metadata|
        {
          :name => key,
          :ensure => :present,
          @metadata => metadata
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
      hash.merge({ record['name'] => record.delete(@metadata.to_s) })
    end.to_yaml.gsub(/^\s{2}/, '') << "\n"
  end

  def self.skip_record? record
    false
  end

  # This is ugly, but it's overridden in ParsedFile with abstract functionality
  # we don't need for our simple provider class.
  # This has been observed to break in Puppet version 3/4 switches.
  def self.valid_attr?(klass, attr_name)
    klass.is_a? Class ? klass.parameters.include?(attr_name) : true
  end
end
