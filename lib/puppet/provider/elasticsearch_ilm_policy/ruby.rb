require 'puppet/provider/elastic_rest'

Puppet::Type.type(:elasticsearch_ilm_policy).provide(
  :ruby,
  :parent => Puppet::Provider::ElasticREST,
  :metadata => :content,
  :metadata_pipeline => [
    lambda { |data| { 'policy' => data['policy'] } },
    lambda { |data| Puppet_X::Elastic.deep_to_i data }
  ],
  :api_uri => '_ilm/policy'
) do
  desc 'A REST API based provider to manage Elasticsearch ILM policies.'

  mk_resource_methods
end
