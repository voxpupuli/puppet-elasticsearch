# frozen_string_literal: true

require_relative '../../helpers/unit/type/elasticsearch_rest_shared_examples'

describe Puppet::Type.type(:elasticsearch_index) do
  let(:resource_name) { 'test-index' }

  include_examples 'REST API types', 'index', :settings

  describe 'settings' do
    let(:resource) do
      described_class.new(
        name: resource_name,
        ensure: 'present',
        settings: {
          'index' => {
            'number_of_replicas' => '0'
          }
        }
      )
    end

    let(:settings) { resource.property(:settings) }

    describe 'insync?' do
      describe 'synced properties' do
        let(:is_settings) do
          {
            'index' => {
              'creation_date' => 1_487_354_196_301,
              'number_of_replicas' => 0,
              'number_of_shards' => 5,
              'provided_name' => 'a',
              'uuid' => 'vtjrcgyerviqllrakslrsw',
              'version' => {
                'created' => 5_020_199
              }
            }
          }
        end

        it 'only enforces defined settings' do
          expect(settings).to be_insync(is_settings)
        end
      end

      describe 'out-of-sync properties' do
        let(:is_settings) do
          {
            'index' => {
              'creation_date' => 1_487_354_196_301,
              'number_of_replicas' => 1,
              'number_of_shards' => 5,
              'provided_name' => 'a',
              'uuid' => 'vtjrcgyerviqllrakslrsw',
              'version' => {
                'created' => 5_020_199
              }
            }
          }
        end

        it 'detects out-of-sync nested values' do
          expect(settings).not_to be_insync(is_settings)
        end
      end
    end
  end
end
