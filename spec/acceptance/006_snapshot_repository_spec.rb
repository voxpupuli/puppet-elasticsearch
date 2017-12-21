require 'spec_helper_acceptance'
require 'json'

describe 'elasticsearch::snapshot_repository', :with_cleanup do
  describe 'valid snapshot repository', :with_cleanup do
    it 'should run successfully' do
      pp = <<-EOS
        class { 'elasticsearch':
          config       => {
            'node.name'    => 'elasticsearch001',
            'cluster.name' => '#{test_settings['cluster_name']}',
            'network.host' => '0.0.0.0',
          },
          repo_version => '#{test_settings['repo_version']}',
        }

        elasticsearch::instance { 'es-01':
          config => {
            'node.name' => 'elasticsearch001',
            'http.port' => '#{test_settings['port_a']}',
            'path.repo' => '/var/lib/elasticsearch'
          }
        }

        elasticsearch::snapshot_repository { 'backup':
          ensure      => 'present',
          api_timeout => 60,
          location    => '/var/lib/elasticsearch/backup',
          require     => Elasticsearch::Instance['es-01']
        }
      EOS

      # Run it twice and test for idempotency
      apply_manifest pp, :catch_failures => true
      apply_manifest pp, :catch_changes => true
    end

    describe port(test_settings['port_a']) do
      it 'open', :with_retries do
        should be_listening
      end
    end

    describe server :container do
      describe http(
        "http://localhost:#{test_settings['port_a']}/_snapshot/backup"
      ) do
        it 'returns the snapshot repository', :with_retries do
          expect(JSON.parse(response.body)['backup'])
            .to include('settings' => a_hash_including('location' => '/var/lib/elasticsearch/backup'))
        end
      end
    end
  end

  describe 'with all settings', :with_cleanup do
    it 'should run successfully' do
      pp = <<-EOS
        class { 'elasticsearch':
          config       => {
            'node.name'    => 'elasticsearch001',
            'cluster.name' => '#{test_settings['cluster_name']}',
            'network.host' => '0.0.0.0',
          },
          repo_version => '#{test_settings['repo_version']}',
        }

        elasticsearch::instance { 'es-01':
          config => {
            'node.name' => 'elasticsearch001',
            'http.port' => '#{test_settings['port_a']}',
            'path.repo' => '/var/lib/elasticsearch'
          }
        }

        elasticsearch::snapshot_repository { 'backup':
          ensure            => 'present',
          api_timeout       => 60,
          location          => '/var/lib/elasticsearch/backup',
          max_restore_rate  => '20mb',
          max_snapshot_rate => '80mb',
          require           => Elasticsearch::Instance['es-01']
        }
      EOS

      # Run it twice and test for idempotency
      apply_manifest pp, :catch_failures => true
      apply_manifest pp, :catch_changes => true
    end

    describe port(test_settings['port_a']) do
      it 'open', :with_retries do
        should be_listening
      end
    end

    describe server :container do
      describe http(
        "http://localhost:#{test_settings['port_a']}/_snapshot/backup"
      ) do
        it 'returns the snapshot repository', :with_retries do
          expect(JSON.parse(response.body)['backup'])
            .to include('settings' => a_hash_including(
              'location'          => '/var/lib/elasticsearch/backup',
              'max_restore_rate'  => '20mb',
              'max_snapshot_rate' => '80mb'
          ))
        end
      end
    end
  end

end
