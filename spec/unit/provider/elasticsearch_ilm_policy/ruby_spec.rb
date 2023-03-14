# frozen_string_literal: true

require_relative '../../../helpers/unit/provider/elasticsearch_rest_shared_examples'

describe Puppet::Type.type(:elasticsearch_ilm_policy).provider(:ruby) do # rubocop:disable RSpec/MultipleMemoizedHelpers
  let(:example1) do
    {
      name: 'foobar1',
      ensure: :present,
      provider: :ruby,
      content: {
        'policy' => {
          'phases' => {
            'cold' => {
              'min_age' => '30d'
            }
          }
        }
      }
    }
  end

  let(:json1) do
    {
      'foobar1' => {
        'policy' => {
          'phases' => {
            'cold' => {
              'min_age' => '30d'
            }
          }
        }
      }
    }
  end
  let(:example2) do
    {
      name: 'foobar2',
      ensure: :present,
      provider: :ruby,
      content: {
        'policy' => {
          'phases' => {
            'warm' => {
              'min_age' => '15d'
            }
          }
        }
      }
    }
  end

  let(:json2) do
    {
      'foobar2' => {
        'policy' => {
          'phases' => {
            'warm' => {
              'min_age' => '15d'
            }
          }
        }
      }
    }
  end

  let(:bare_resource) do
    JSON.dump(
      {}
    )
  end

  let(:resource) { Puppet::Type::Elasticsearch_ilm_policy.new props }
  let(:provider) { described_class.new resource }
  let(:props) do
    {
      name: 'foo',
      content: {}
    }
  end

  include_examples 'REST API', 'ilm/policy', '_ilm/policy/foo'
end
