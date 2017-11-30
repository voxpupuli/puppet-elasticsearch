require 'spec_helper_acceptance'
require 'helpers/acceptance/tests/class_shared_examples.rb'

describe 'elasticsearch class v2' do
  let(:manifest) do
    <<-MANIFEST
        class { 'elasticsearch':
          config => {
            'cluster.name' => '#{test_settings['cluster_name']}',
            'network.host' => '0.0.0.0',
          },
          repo_version => '2.x',
        }

        elasticsearch::instance { 'es-01':
          config => {
            'node.name' => 'elasticsearch001',
            'http.port' => '#{test_settings['port_a']}'
          }
        }
      MANIFEST
  end

  include_examples 'class manifests'
end
