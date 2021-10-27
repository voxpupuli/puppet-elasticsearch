# frozen_string_literal: true

require_relative '../../../helpers/unit/provider/elasticsearch_rest_shared_examples'

describe Puppet::Type.type(:elasticsearch_snapshot_repository).provider(:ruby) do # rubocop:disable RSpec/MultipleMemoizedHelpers
  let(:example1) do
    {
      name: 'foobar1',
      ensure: :present,
      provider: :ruby,
      location: '/bak1',
      type: 'fs',
      compress: true
    }
  end

  let(:json1) do
    {
      'foobar1' => {
        'type' => 'fs',
        'settings' => {
          'compress' => true,
          'location' => '/bak1'
        }
      }
    }
  end

  let(:example2) do
    {
      name: 'foobar2',
      ensure: :present,
      provider: :ruby,
      location: '/bak2',
      type: 'fs',
      compress: true
    }
  end

  let(:json2) do
    {
      'foobar2' => {
        'type' => 'fs',
        'settings' => {
          'compress' => true,
          'location' => '/bak2'
        }
      }
    }
  end

  let(:bare_resource) do
    JSON.dump(
      'type' => 'fs',
      'settings' => {
        'compress' => true,
        'location' => '/backups'
      }
    )
  end

  let(:resource) { Puppet::Type::Elasticsearch_snapshot_repository.new props }
  let(:provider) { described_class.new resource }
  let(:props) do
    {
      name: 'backup',
      type: 'fs',
      compress: true,
      location: '/backups'
    }
  end

  include_examples 'REST API', 'snapshot', '_snapshot/backup'
end
