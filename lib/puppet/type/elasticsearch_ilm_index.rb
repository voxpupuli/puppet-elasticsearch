$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..'))

require 'puppet_x/elastic/deep_implode'
require 'puppet_x/elastic/deep_to_i'
require 'puppet_x/elastic/elasticsearch_rest_resource'
require 'puppet_x/elastic/es_versioning'

Puppet::Type.newtype(:elasticsearch_ilm_index) do
  extend ElasticsearchRESTResource

  desc 'Manages Elasticsearch ILM managed indicies.'

  ensurable

  newparam(:name, :namevar => true) do
    desc 'ILM index alias name.'
  end

  newparam(:pattern) do
    desc 'Pattern used by ILM for naming managed indicies.'
  end

  newproperty(:content) do
    desc 'The ILM index bootstrapping document to apply.'

    validate do |value|
      raise Puppet::Error, 'hash expected' unless value.is_a? Hash
    end

    def insync?(_is)
      # If puppet is checking insync, then this index set already exists
      # and never needs to be bootstrapped again.
      true
    end
  end
end # of newtype
