# frozen_string_literal: true

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..'))

require 'puppet/file_serving/content'
require 'puppet/file_serving/metadata'

require 'puppet_x/elastic/deep_implode'
require 'puppet_x/elastic/deep_to_i'
require 'puppet_x/elastic/deep_to_s'
require 'puppet_x/elastic/elasticsearch_rest_resource'

Puppet::Type.newtype(:elasticsearch_slm_policy) do
  extend ElasticsearchRESTResource

  desc 'Manages Elasticsearch SLM policies.'

  ensurable

  newparam(:name, namevar: true) do
    desc 'Policy name.'
  end

  newproperty(:content) do
    desc 'Structured content of policy.'

    validate do |value|
      raise Puppet::Error, 'hash expected' unless value.is_a? Hash
    end

    def insync?(value)
      Puppet_X::Elastic.deep_implode(value) == \
        Puppet_X::Elastic.deep_implode(should)
    end

    munge do |value|
      Puppet_X::Elastic.deep_to_i(Puppet_X::Elastic.deep_to_s(value))
    end
  end

  newparam(:source) do
    desc 'Puppet source to file containing SLM policy contents.'

    validate do |value|
      raise Puppet::Error, 'string expected' unless value.is_a? String
    end
  end

  # rubocop:disable Style/SignalException
  validate do
    # Ensure that at least one source of ILM policy content has been provided
    if self[:ensure] == :present
      fail Puppet::ParseError, '"content" or "source" required' \
        if self[:content].nil? && self[:source].nil?

      if !self[:content].nil? && !self[:source].nil?
        fail(
          Puppet::ParseError,
          "'content' and 'source' cannot be simultaneously defined"
        )
      end
    end

    # If a source was passed, retrieve the source content from Puppet's
    # FileServing indirection and set the content property
    unless self[:source].nil?
      fail(format('Could not retrieve source %s', self[:source])) unless Puppet::FileServing::Metadata.indirection.find(self[:source])

      tmp = if !catalog.nil? \
                && catalog.respond_to?(:environment_instance)
              Puppet::FileServing::Content.indirection.find(
                self[:source],
                environment: catalog.environment_instance
              )
            else
              Puppet::FileServing::Content.indirection.find(self[:source])
            end

      fail(format('Could not find any content at %s', self[:source])) unless tmp

      self[:content] = PSON.load(tmp.content)
    end
  end
  # rubocop:enable Style/SignalException
end
