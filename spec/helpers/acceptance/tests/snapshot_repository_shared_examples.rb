require 'json'
require 'helpers/acceptance/tests/manifest_shared_examples'

# Main entrypoint for snapshot tests
shared_examples 'snapshot repository acceptance tests' do
  describe 'elasticsearch::snapshot_repository', :with_cleanup do
    es_config = {
      'http.port' => 9200,
      'node.name' => 'elasticsearchSnapshot01',
      'path.repo' => '/var/lib/elasticsearch'
    }

    # Override the manifest in order to populate 'path.repo'
    let(:manifest) do
      package = if not v[:is_snapshot]
                  <<-MANIFEST
                    # Hard version set here due to plugin incompatibilities.
                    version => '#{v[:elasticsearch_full_version]}',
                  MANIFEST
                else
                  <<-MANIFEST
                    manage_repo => false,
                    package_url => '#{v[:snapshot_package]}',
                  MANIFEST
                end

      <<-MANIFEST
        api_timeout => 60,
        config => {
          'cluster.name' => '#{v[:cluster_name]}',
          'http.bind_host' => '0.0.0.0',
  #{es_config.map { |k, v| "        '#{k}' => '#{v}'," }.join("\n")}
        },
        jvm_options => [
          '-Xms128m',
          '-Xmx128m',
        ],
        oss => #{v[:oss]},
        #{package}
      MANIFEST
    end

    let(:manifest_class_parameters) { 'restart_on_change => true' }

    let(:extra_manifest) do
      <<-MANIFEST
        elasticsearch::snapshot_repository { 'backup':
          ensure            => 'present',
          api_timeout       => 60,
          location          => '/var/lib/elasticsearch/backup',
          max_restore_rate  => '20mb',
          max_snapshot_rate => '80mb',
        }
      MANIFEST
    end

    include_examples('manifest application', es_config)

    es_port = es_config['http.port']
    describe port(es_port) do
      it 'open', :with_retries do
        should be_listening
      end
    end

    describe server :container do
      describe http(
        "http://localhost:#{es_port}/_snapshot/backup"
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
