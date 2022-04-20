# frozen_string_literal: true

require_relative '../../helpers/unit/type/elasticsearch_rest_shared_examples'

describe Puppet::Type.type(:elasticsearch_slm_policy) do
  let(:resource_name) { 'test_slm_policy' }

  include_examples 'REST API types', 'slm_policy', :content
end
