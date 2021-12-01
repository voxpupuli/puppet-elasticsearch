require 'json'
require 'helpers/acceptance/tests/manifest_shared_examples'

shared_examples 'basic acceptance tests' do |es_config|
  include_examples('manifest application')

  describe package("elasticsearch#{v[:oss] ? '-oss' : ''}") do
    it { should be_installed
      .with_version(v[:elasticsearch_full_version]) }
  end

  %w[
    /etc/elasticsearch
    /usr/share/elasticsearch
    /var/lib/elasticsearch
  ].each do |dir|
    describe file(dir) do
      it { should be_directory }
    end
  end

  describe 'resources' do
    describe service('elasticsearch') do
      it { send(es_config.empty? ? :should_not : :should, be_enabled) }
      it { send(es_config.empty? ? :should_not : :should, be_running) }
    end

    unless es_config.empty?
      describe file(pid_file) do
        it { should be_file }
        its(:content) { should match(/[0-9]+/) }
      end

      describe file('/etc/elasticsearch/elasticsearch.yml') do
        it { should be_file }
        it { should contain "name: #{es_config['node.name']}" }
      end
    end

    unless es_config.empty?
      es_port = es_config['http.port']
      describe port(es_port) do
        it 'open', :with_retries do
          should be_listening
        end
      end

      describe server :container do
        describe http("http://localhost:#{es_port}/_nodes/_local") do
          it 'serves requests', :with_retries do
            expect(response.status).to eq(200)
          end

          it 'uses the default data path', :with_retries do
            json = JSON.parse(response.body)['nodes'].values.first
            data_dir = ['/var/lib/elasticsearch']
            expect(
              json['settings']['path']
            ).to include(
              'data' => data_dir
            )
          end
        end
      end
    end
  end
end
