# frozen_string_literal: true

require 'json'
require 'helpers/acceptance/tests/manifest_shared_examples'
require 'helpers/acceptance/tests/plugin_api_shared_examples'

shared_examples 'plugin upgrade acceptance tests' do |plugin|
  describe 'elasticsearch::plugin' do
    # Ensure that instances are restarted to include plugins
    let(:manifest_class_parameters) { 'restart_on_change => true' }

    instances = {
      'es-01' => {
        'config' => {
          'http.port' => 9200,
          'node.name' => 'elasticsearch001'
        }
      }
    }

    describe 'installation' do
      describe 'upgrades', :with_cleanup do
        context 'initial installation' do
          let(:extra_manifest) do
            <<-MANIFEST
              elasticsearch::plugin { '#{plugin[:repository]}-#{plugin[:name]}/v#{plugin[:initial]}':
                instances => 'es-01',
              }
            MANIFEST
          end

          include_examples(
            'manifest application',
            instances
          )

          include_examples(
            'plugin API response',
            instances,
            'contains the initial plugin version',
            'name' => plugin[:name],
            'version' => plugin[:initial]
          )
        end

        describe 'upgrading' do
          let(:extra_manifest) do
            <<-MANIFEST
              elasticsearch::plugin { '#{plugin[:repository]}-#{plugin[:name]}/v#{plugin[:upgraded]}':
                instances => 'es-01',
              }
            MANIFEST
          end

          include_examples(
            'manifest application',
            instances
          )

          include_examples(
            'plugin API response',
            instances,
            'contains the upgraded plugin version',
            'name' => plugin[:name],
            'version' => plugin[:upgraded]
          )
        end
      end
    end
  end
end
