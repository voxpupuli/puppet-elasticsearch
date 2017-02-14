require 'json'

require_relative '../elasticsearch_rest'

# rubocop:disable Metrics/BlockLength
describe Puppet::Type.type(:elasticsearch_template).provider(:ruby) do
  let(:example_1) do
    {
      :name => 'foobar1',
      :ensure => :present,
      :provider => :ruby,
      :content => {
        'aliases' => {},
        'mappings' => {},
        'settings' => {},
        'template' => 'foobar1-*',
        'order' => 1
      }
    }
  end

  let(:json_1) do
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

  let(:example_2) do
    {
      :name => 'foobar2',
      :ensure => :present,
      :provider => :ruby,
      :content => {
        'aliases' => {},
        'mappings' => {},
        'settings' => {},
        'template' => 'foobar2-*',
        'order' => 2
      }
    }
  end

  let(:json_2) do
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

  include_examples 'REST API', 'template'
end
