# frozen_string_literal: true

require_relative '../../helpers/unit/type/elasticsearch_rest_shared_examples'

describe Puppet::Type.type(:elasticsearch_ilm_policy) do
  let(:resource_name) { 'test_ilm_policy' }

  include_examples 'REST API types', 'ilm_policy', :content
end
