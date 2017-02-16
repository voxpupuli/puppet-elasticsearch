require 'puppet/provider/elastic_rest'

Puppet::Type.type(:elasticsearch_pipeline).provide(
  :ruby,
  :parent => Puppet::Provider::ElasticREST,
  :api_uri => '_ingest/pipeline'
) do
  desc 'A REST API based provider to manage Elasticsearch ingest pipelines.'

  mk_resource_methods
end
