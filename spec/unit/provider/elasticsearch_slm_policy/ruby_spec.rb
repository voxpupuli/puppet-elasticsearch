# frozen_string_literal: true

require_relative '../../../helpers/unit/provider/elasticsearch_rest_shared_examples'

describe Puppet::Type.type(:elasticsearch_slm_policy).provider(:ruby) do # rubocop:disable RSpec/MultipleMemoizedHelpers
  let(:example1) do
    {
      name: 'foobar1',
      ensure: :present,
      provider: :ruby,
      content: {
        'name' => '<backup-{now/d}>',
        'schedule' => '0 30 1 * * ?',
        'repository' => 'backup',
        'config' => {},
        'retention' => {
          'expire_after' => '60d',
          'min_count' => 2,
          'max_count' => 10
        }
      }
    }
  end

  let(:json1) do
    {
      'foobar1' => {
        'policy' => {
          'name' => '<backup-{now/d}>',
          'schedule' => '0 30 1 * * ?',
          'repository' => 'backup',
          'config' => {},
          'retention' => {
            'expire_after' => '60d',
            'min_count' => 2,
            'max_count' => 10
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
        'name' => '<backup2-{now/d}>',
        'schedule' => '0 30 1 * * ?',
        'repository' => 'backup',
        'config' => {},
        'retention' => {
          'expire_after' => '60d',
          'min_count' => 2,
          'max_count' => 10
        }
      }
    }
  end

  let(:json2) do
    {
      'foobar2' => {
        'policy' => {
          'name' => '<backup2-{now/d}>',
          'schedule' => '0 30 1 * * ?',
          'repository' => 'backup',
          'config' => {},
          'retention' => {
            'expire_after' => '60d',
            'min_count' => 2,
            'max_count' => 10
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

  let(:resource) { Puppet::Type::Elasticsearch_slm_policy.new props }
  let(:provider) { described_class.new resource }
  let(:props) do
    {
      name: 'foo',
      content: {}
    }
  end

  include_examples 'REST API', 'slm/policy', '_slm/policy/foo'
end
