# frozen_string_literal: true

require 'puppet/provider/elastic_rest'

Puppet::Type.type(:elasticsearch_license).provide(
  :ruby,
  parent: Puppet::Provider::ElasticREST,
  metadata: :content,
  metadata_pipeline: [
    ->(data) { Puppet_X::Elastic.deep_to_s data },
    ->(data) { Puppet_X::Elastic.deep_to_i data }
  ],
  api_uri: '_license',
  query_string: {
    'acknowledge' => 'true'
  }
) do
  desc 'A REST API based provider to manage Elasticsearch licenses.'

  mk_resource_methods

  def self.process_body(body)
    JSON.parse(body).map do |object_name, api_object|
      {
        :name => object_name,
        :ensure => :present,
        metadata => { 'licenses' => process_metadata(api_object) },
        :provider => name
      }
    end
  end
end
