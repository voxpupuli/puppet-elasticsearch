# frozen_string_literal: true

require_relative '../../../helpers/unit/provider/elasticsearch_rest_shared_examples'

describe Puppet::Type.type(:elasticsearch_template).provider(:ruby) do # rubocop:disable RSpec/MultipleMemoizedHelpers
  let(:example1) do
    {
      name: 'foobar1',
      ensure: :present,
      provider: :ruby,
      content: {
        'aliases' => {},
        'mappings' => {},
        'settings' => {},
        'template' => 'foobar1-*',
        'order' => 1
      }
    }
  end

  let(:json1) do
    {
      'foobar1' => {
        'aliases' => {},
        'mappings' => {},
        'order' => 1,
        'settings' => {},
        'template' => 'foobar1-*'
      }
    }
  end

  let(:example2) do
    {
      name: 'foobar2',
      ensure: :present,
      provider: :ruby,
      content: {
        'aliases' => {},
        'mappings' => {},
        'settings' => {},
        'template' => 'foobar2-*',
        'order' => 2
      }
    }
  end

  let(:json2) do
    {
      'foobar2' => {
        'aliases' => {},
        'mappings' => {},
        'order' => 2,
        'settings' => {},
        'template' => 'foobar2-*'
      }
    }
  end

  let(:bare_resource) do
    JSON.dump(
      'order' => 0,
      'aliases' => {},
      'mappings' => {},
      'template' => 'fooindex-*'
    )
  end

  let(:resource) { Puppet::Type::Elasticsearch_template.new props }
  let(:provider) { described_class.new resource }
  let(:props) do
    {
      name: 'foo',
      content: {
        'template' => 'fooindex-*'
      }
    }
  end

  include_examples 'REST API', 'template', '_template/foo'
end
