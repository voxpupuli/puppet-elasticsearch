# frozen_string_literal: true

require_relative '../../../helpers/unit/provider/elasticsearch_rest_shared_examples'

describe Puppet::Type.type(:elasticsearch_component_template).provider(:ruby) do # rubocop:disable RSpec/MultipleMemoizedHelpers
  let(:example1) do
    {
      name: 'foobar1',
      ensure: :present,
      provider: :ruby,
      content: {
        'template' => {
          'mappings' => {
            'properties' => {
              'dummy1' => {
                'type' => 'keyword'
              }
            }
          }
        }
      }
    }
  end

  let(:json1) do
    {
      'component_templates' => [
        {
          'name' => 'foobar1',
          'component_template' => {
            'template' => {
              'mappings' => {
                'properties' => {
                  'dummy1' => {
                    'type' => 'keyword'
                  }
                }
              }
            }
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
        'template' => {
          'mappings' => {
            'properties' => {
              'dummy2' => {
                'type' => 'keyword'
              }
            }
          }
        }
      }
    }
  end

  let(:json2) do
    {
      'component_templates' => [
        {
          'name' => 'foobar2',
          'component_template' => {
            'template' => {
              'mappings' => {
                'properties' => {
                  'dummy2' => {
                    'type' => 'keyword'
                  }
                }
              }
            }
          }
        }
      ]
    }
  end

  let(:bare_resource) do
    JSON.dump(
      {}
    )
  end

  let(:resource) { Puppet::Type::Elasticsearch_component_template.new props }
  let(:provider) { described_class.new resource }
  let(:props) do
    {
      name: 'foo',
      content: {}
    }
  end

  include_examples 'REST API', 'component_template', '_component_template/foo'
end
