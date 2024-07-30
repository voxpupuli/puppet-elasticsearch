# frozen_string_literal: true

require 'puppet/provider/elastic_rest'

Puppet::Type.type(:elasticsearch_pipeline).provide(
  :ruby,
  parent: Puppet::Provider::ElasticREST,
  metadata: :content,
  api_uri: '_license?acknowledge=true'
) do
  desc 'A REST API based provider to manage Elasticsearch licenses.'

  mk_resource_methods
end
