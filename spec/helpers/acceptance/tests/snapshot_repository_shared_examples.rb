require 'json'
require 'helpers/acceptance/tests/manifest_shared_examples'

# Main entrypoint for snapshot tests
shared_examples 'snapshot repository acceptance tests' do
  describe 'elasticsearch::snapshot_repository', :with_cleanup do
    let(:manifest_class_parameters) { 'restart_on_change => true' }

    let(:extra_manifest) do
      <<-MANIFEST
        elasticsearch::snapshot_repository { 'backup':
          ensure            => 'present',
          api_timeout       => 60,
          location          => '/var/lib/elasticsearch/backup',
          max_restore_rate  => '20mb',
          max_snapshot_rate => '80mb',
          require           => Elasticsearch::Instance['es-01']
        }
      MANIFEST
    end

    instance = {
      'es-01' => {
        'config' => {
          'http.port' => 9200,
          'path.repo' => '/var/lib/elasticsearch'
        }
      }
    }
    instance['es-01']['config']['path.repo'] = [instance['es-01']['config']['path.repo']] if v[:elasticsearch_major_version] > 2

    include_examples('manifest application', instance)

    describe port(9200) do
      it 'open', :with_retries do
        should be_listening
      end
    end

    describe server :container do
      describe http(
        'http://localhost:9200/_snapshot/backup'
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
