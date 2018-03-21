require 'spec_helper_acceptance'
require 'helpers/acceptance/tests/basic_shared_examples.rb'
require 'helpers/acceptance/tests/template_shared_examples.rb'
require 'helpers/acceptance/tests/removal_shared_examples.rb'
require 'helpers/acceptance/tests/plugin_shared_examples.rb'
require 'helpers/acceptance/tests/snapshot_repository_shared_examples.rb'

describe 'elasticsearch class v2' do
  local_plugin_path = Dir[
    "#{RSpec.configuration.test_settings['files_dir']}/elasticsearch-plugin-2*"
  ].first
  local_plugin_name = File.basename(local_plugin_path).split('_').last.split('.').first

  let(:manifest) do
    <<-MANIFEST
      class { 'elasticsearch':
        config => {
          'cluster.name' => '#{test_settings['cluster_name']}',
          'network.host' => '0.0.0.0',
        },
        repo_version => '2.x',
        # Hard version set here due to plugin incompatibilities.
        version => '2.4.1',
      }
    MANIFEST
  end

  # Single-node
  include_examples(
    'basic acceptance tests',
    'es-01' => {
      'http.port' => 9200,
      'node.name' => 'elasticsearch001'
    }
  )

  # Dual-node
  include_examples(
    'basic acceptance tests',
    'es-01' => {
      'http.port' => 9200,
      'node.name' => 'elasticsearch001'
    },
    'es-02' => {
      'http.port' => 9201,
      'node.name' => 'elasticsearch002'
    }
  )

  include_examples 'module removal', %w[es-01 es-02]

  include_examples(
    'template operations',
    {
      'es-01' => {
        'http.port' => 9200,
        'node.name' => 'elasticsearch001'
      }
    },
    test_settings['template']
  )

  context 'with restart_on_changes' do
    let(:manifest) do
      <<-MANIFEST
        class { 'elasticsearch':
          config => {
            'cluster.name' => '#{test_settings['cluster_name']}',
            'network.host' => '0.0.0.0',
          },
          repo_version => '2.x',
          restart_on_change => true,
          version => '2.4.1',
        }
      MANIFEST
    end

    include_examples(
      'plugin acceptance tests',
      {
        'es-01' => {
          'http.port' => 9200,
          'node.name' => 'elasticsearch001'
        }
      },
      :github => {
        :name => 'kopf',
        :initial => '2.0.1',
        :upgraded => '2.1.2',
        :repository => 'lmenezes/elasticsearch-'
      },
      :official => 'analysis-icu',
      :offline => {
        :name => local_plugin_name,
        :path => local_plugin_path
      },
      :remote => {
        :url => 'https://github.com/royrusso/elasticsearch-HQ/archive/v2.0.3.zip',
        :name => 'hq'
      }
    )
  end

  # Tests for elasticsearch::snapshot resources
  include_examples 'snapshot repository acceptance tests'
end
