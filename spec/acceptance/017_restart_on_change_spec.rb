require 'spec_helper_acceptance'

describe 'elasticsearch::restart_on_change', :with_cleanup do
  describe 'initial setup' do
    describe 'manifest' do
      pp = <<-EOS
        class { 'elasticsearch':
          config => {
            'cluster.name' => '#{test_settings['cluster_name']}'
          },
          manage_repo => true,
          repo_version => '#{test_settings['repo_version']}',
          java_install => true,
          restart_on_change => false
        }

        elasticsearch::instance { 'es-01':
          config => {
            'node.name' => 'elasticsearch001',
            'http.port' => '#{test_settings['port_a']}'
          }
        }

        elasticsearch::plugin { 'lmenezes/elasticsearch-kopf':
          instances => 'es-01'
        }
      EOS

      it 'applies cleanly ' do
        apply_manifest pp, :catch_failures => true
      end
      it 'is idempotent' do
        apply_manifest pp , :catch_changes  => true
      end
    end
  end

  describe 'config change' do
    describe 'manifest' do
      pp = <<-EOS
        class { 'elasticsearch':
          config => {
            'cluster.name' => '#{test_settings['cluster_name']}'
          },
          manage_repo => true,
          repo_version => '#{test_settings['repo_version']}',
          java_install => true,
          restart_on_change => false
        }

        elasticsearch::instance { 'es-01':
          config => {
            'node.name' => 'elasticsearch002',
            'http.port' => '#{test_settings['port_a']}'
          }
        }

        elasticsearch::plugin { 'lmenezes/elasticsearch-kopf':
          instances => 'es-01'
        }
      EOS

      it 'applies cleanly ' do
        apply_manifest pp, :catch_failures => true
      end
      it 'is idempotent' do
        apply_manifest pp , :catch_changes  => true
      end
    end

    describe file('/etc/elasticsearch/es-01/elasticsearch.yml') do
      it { should be_file }
      it { should contain 'name: elasticsearch002' }
    end

    describe port(test_settings['port_a']) do
      it 'open', :with_retries do should be_listening end
    end

    describe server :container do
      describe http(
        "http://localhost:#{test_settings['port_a']}/_nodes/_local"
      ) do
        it 'returns the correct node name', :with_retries do
          json = JSON.parse(response.body)['nodes'].values.first
          expect(json['name']).to eq('elasticsearch001')
        end
      end
    end
  end
end
