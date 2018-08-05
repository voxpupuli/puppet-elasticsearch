$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..'))

require 'puppet/file_serving/content'
require 'puppet/file_serving/metadata'

require 'puppet_x/elastic/deep_implode'
require 'puppet_x/elastic/deep_to_s'
require 'puppet_x/elastic/elasticsearch_rest_resource'

Puppet::Type.newtype(:elasticsearch_document) do
  extend ElasticsearchRESTResource

  desc 'Manages Elasticsearch index documents.'

  ensurable

  newparam(:name, :namevar => true) do
    desc 'The full path to where the document will be stored in Elasticsearch.'

    validate do |value|
      raise Puppet::Error, 'string expected' unless value.is_a? String
      elems = value.split('/')
      raise Puppet::Error, "name must be of form <index>/<type>/<id>, not #{value}" unless elems.length == 3
    end
  end

  newproperty(:content) do
    desc 'Structured content of document.'

    validate do |value|
      raise Puppet::Error, 'hash expected' unless value.is_a? Hash
    end

    def insync?(is)
      Puppet_X::Elastic.deep_implode(is) == \
        Puppet_X::Elastic.deep_implode(should)
    end
  end

  newparam(:source) do
    desc 'Puppet source to file containing document contents.'

    validate do |value|
      raise Puppet::Error, 'string expected' unless value.is_a? String
    end
  end

  # rubocop:disable Style/SignalException
  validate do
    # Ensure that at least one source of template content has been provided
    if self[:ensure] == :present
      raise Puppet::ParseError, '"content" or "source" required' \
        if self[:content].nil? and self[:source].nil?
      if !self[:content].nil? and !self[:source].nil?
        raise(
          Puppet::ParseError,
          "'content' and 'source' cannot be simultaneously defined"
        )
      end
    end

    # If a source was passed, retrieve the source content from Puppet's
    # FileServing indirection and set the content property
    unless self[:source].nil?
      unless Puppet::FileServing::Metadata.indirection.find(self[:source])
        fail(format('Could not retrieve source %s', self[:source]))
      end

      tmp = if !catalog.nil? \
                and catalog.respond_to?(:environment_instance)
              Puppet::FileServing::Content.indirection.find(
                self[:source],
                :environment => catalog.environment_instance
              )
            else
              Puppet::FileServing::Content.indirection.find(self[:source])
            end

      fail(format('Could not find any content at %s', self[:source])) unless tmp
      self[:content] = PSON.load(tmp.content)
    end
  end
end # of newtype
