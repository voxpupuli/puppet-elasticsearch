# frozen_string_literal: true

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', '..'))

require 'puppet/provider/elastic_rest'

require 'puppet_x/elastic/deep_to_i'
require 'puppet_x/elastic/deep_to_s'

Puppet::Type.type(:elasticsearch_index_template).provide(
  :ruby,
  parent: Puppet::Provider::ElasticREST,
  api_uri: '_index_template',
  metadata: :content,
  metadata_pipeline: [
    lambda { |data|
      # As api returns values keyed under index_template
      data.merge!(data['index_template']) if data['index_template'].is_a? Hash
      data.delete('index_template')
    },
    ->(data) { Puppet_X::Elastic.deep_to_s data },
    ->(data) { Puppet_X::Elastic.deep_to_i data }
  ]
) do
  desc 'A REST API based provider to manage Elasticsearch index templates.'

  mk_resource_methods

  # We need to override parent since actual data comes as array under index_templates key
  def self.process_body(body)
    JSON.parse(body).fetch('index_templates', []).map do |item|
      {
        :name => item['name'],
        :ensure => :present,
        metadata => process_metadata(item.keep_if { |key| key != 'name' }),
        :provider => name
      }
    end
  end
end
