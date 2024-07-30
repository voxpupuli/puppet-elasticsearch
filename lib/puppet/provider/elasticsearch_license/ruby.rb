# frozen_string_literal: true

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', '..'))

require 'puppet/provider/elastic_rest'

require 'puppet_x/elastic/deep_to_i'
require 'puppet_x/elastic/deep_to_s'

Puppet::Type.type(:elasticsearch_license).provide(
  :ruby,
  parent: Puppet::Provider::ElasticREST,
  api_uri: '_license?acknowledge=true',
  metadata: :content,
  metadata_pipeline: [
    ->(data) { Puppet_X::Elastic.deep_to_s data },
    ->(data) { Puppet_X::Elastic.deep_to_i data }
  ]
) do
  desc 'A REST API based provider to manage Elasticsearch licenses.'

  mk_resource_methods

  def self.process_body(body)
    Puppet.debug('Got to license.process_body')

    JSON.parse(body).map do |object_name, api_object|
      {
        name: object_name,
        ensure: :present,
        metadata => { 'licenses' => process_metadata(api_object) },
        provider: name
      }.compact
    end
  end
end
