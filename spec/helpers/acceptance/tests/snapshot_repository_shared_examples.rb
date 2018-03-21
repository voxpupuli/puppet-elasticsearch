require 'json'
require 'helpers/acceptance/tests/manifest_shared_examples'

# Main entrypoint for snapshot tests
shared_examples 'snapshot repository acceptance tests' do
  describe 'elasticsearch::snapshot_repository', :with_cleanup do
    include_examples(
      'manifest application',
      {
        'es-01' => {
          'http.port' => 9200,
          'path.repo' => '/var/lib/elasticsearch'
        }
      },
      <<-TEMPLATE
        elasticsearch::snapshot_repository { 'backup':
          ensure            => 'present',
          api_timeout       => 60,
          location          => '/var/lib/elasticsearch/backup',
          max_restore_rate  => '20mb',
          max_snapshot_rate => '80mb',
          require           => Elasticsearch::Instance['es-01']
        }
      TEMPLATE
    )

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
