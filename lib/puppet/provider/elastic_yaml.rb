# frozen_string_literal: true

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..'))

require 'puppet/provider/elastic_parsedfile'
require 'puppet/util/package'
require 'puppet_x/elastic/hash'

# Provider for yaml-based Elasticsearch configuration files.
class Puppet::Provider::ElasticYaml < Puppet::Provider::ElasticParsedFile
  class << self
    attr_accessor :metadata
  end

  # Transform a given string into a Hash-based representation of the
  # provider.
  def self.parse(text)
    yaml = YAML.safe_load text
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

  # Transform a given list of provider records into yaml-based
  # representation.
  def self.to_file(records)
    yaml = records.map do |record|
      # Convert top-level symbols to strings
      record.transform_keys(&:to_s)
    end
    yaml = yaml.reduce({}) do |hash, record|
      # Flatten array of hashes into single hash
      hash.merge(record['name'] => record.delete(@metadata.to_s))
    end
    yaml = yaml.extend(Puppet_X::Elastic::SortedHash).to_yaml.split("\n")

    yaml.shift if yaml.first =~ %r{---}
    yaml = yaml.join("\n")

    yaml << "\n"
  end

  def self.skip_record?(_record)
    false
  end

  # This is ugly, but it's overridden in ParsedFile with abstract
  # functionality we don't need for our simple provider class.
  # This has been observed to break in Puppet version 3/4 switches.
  def self.valid_attr?(klass, attr_name)
    klass.is_a? Class ? klass.parameters.include?(attr_name) : true
  end
end
