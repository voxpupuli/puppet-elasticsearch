$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', '..'))

require 'puppet_x/elastic/elasticsearch_rest_resource'

Puppet::Type.newtype(:elasticsearch_pipeline) do
  extend ElasticsearchRESTResource

  desc 'Manages Elasticsearch indexing pipelines.'

  ensurable do
    defaultvalues
    defaultto :present
  end

  newparam(:name, :namevar => true) do
    desc 'Pipeline name.'
  end

  newproperty(:description) do
    desc 'Description of the pipeline.'

    validate do |value|
      raise Puppet::Error, 'string expected' unless value.is_a? String
    end
  end

  newproperty(:processors) do
    desc 'Array of processors for the pipeline.'

    validate do |value|
      raise Puppet::Error, 'array expected' unless value.is_a? Array
    end
  end
end # of newtype
