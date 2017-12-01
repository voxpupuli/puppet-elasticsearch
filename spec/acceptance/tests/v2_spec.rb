require 'spec_helper_acceptance'
require 'helpers/acceptance/tests/basic_shared_examples.rb'
require 'helpers/acceptance/tests/template_shared_examples.rb'
require 'helpers/acceptance/tests/removal_shared_examples.rb'

describe 'elasticsearch class v2' do
  let(:manifest) do
    <<~MANIFEST
      class { 'elasticsearch':
        config => {
          'cluster.name' => '#{test_settings['cluster_name']}',
          'network.host' => '0.0.0.0',
        },
        repo_version => '2.x',
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
end
