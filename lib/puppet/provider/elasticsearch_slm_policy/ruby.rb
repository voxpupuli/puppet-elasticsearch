# frozen_string_literal: true

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', '..'))

require 'puppet/provider/elastic_rest'

require 'puppet_x/elastic/deep_to_i'
require 'puppet_x/elastic/deep_to_s'

Puppet::Type.type(:elasticsearch_slm_policy).provide(
  :ruby,
  parent: Puppet::Provider::ElasticREST,
  api_uri: '_slm/policy',
  metadata: :content,
  metadata_pipeline: [
    # Since API returns actual policy keyed under policy.
    ->(data) { data['policy'] },
    ->(data) { Puppet_X::Elastic.deep_to_s data },
    ->(data) { Puppet_X::Elastic.deep_to_i data }
  ]
) do
  desc 'A REST API based provider to manage Elasticsearch ILM policies.'

  mk_resource_methods
end
