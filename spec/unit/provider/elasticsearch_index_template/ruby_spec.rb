# frozen_string_literal: true

require_relative '../../../helpers/unit/provider/elasticsearch_rest_shared_examples'

describe Puppet::Type.type(:elasticsearch_index_template).provider(:ruby) do # rubocop:disable RSpec/MultipleMemoizedHelpers
  let(:example1) do
    {
      name: 'foobar1',
      ensure: :present,
      provider: :ruby,
      content: {
        'index_patterns' => ['foorbar1-*']
      }
    }
  end

  let(:json1) do
    {
      'index_templates' => [
        {
          'name' => 'foobar1',
          'index_template' => {
            'index_patterns' => [
              'foorbar1-*'
            ],
          }
        }
      ]
    }
  end
  let(:example2) do
    {
      name: 'foobar2',
      ensure: :present,
      provider: :ruby,
      content: {
        'index_patterns' => ['foorbar2-*'],
        'template' => {
          'settings' => {
            'number_of_shards' => 1
          }
        }
      }
    }
  end

  let(:json2) do
    {
      'index_templates' => [
        {
          'name' => 'foobar2',
          'index_template' => {
            'index_patterns' => [
              'foorbar2-*'
            ],
            'template' => {
              'settings' => {
                'number_of_shards' => 1
              }
            },
          }
        }
      ]
    }
  end

  let(:bare_resource) do
    JSON.dump(
      'composed_of' => [],
      'index_patterns' => ['fooindex-*']
    )
  end

  let(:resource) { Puppet::Type::Elasticsearch_index_template.new props }
  let(:provider) { described_class.new resource }
  let(:props) do
    {
      name: 'foo',
      content: {
        'index_patterns' => ['fooindex-*'],
        'composed_of' => []
      }
    }
  end

  include_examples 'REST API', 'index_template', '_index_template/foo'
end
