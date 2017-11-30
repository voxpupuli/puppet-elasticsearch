require 'json'

shared_examples 'basic acceptance tests' do |instance, es_port|
  context 'manifest' do
    it 'applies cleanly' do
      apply_manifest manifest, :catch_failures => true
    end

    it 'is idempotent' do
      apply_manifest manifest, :catch_changes => true
    end

    describe service("elasticsearch-#{instance}") do
      it { should be_enabled }
      it { should be_running }
    end

    describe package('elasticsearch') do
      it { should be_installed }
    end

    describe file(pid_for(instance)) do
      it { should be_file }
      its(:content) { should match(/[0-9]+/) }
    end

    describe file("/etc/elasticsearch/#{instance}/elasticsearch.yml") do
      it { should be_file }
      it { should contain "name: #{node_name}" }
      it { should contain "/var/lib/elasticsearch/#{instance}" }
    end

    describe file('/usr/share/elasticsearch/templates_import') do
      it { should be_directory }
    end

    describe file("/var/lib/elasticsearch/#{instance}") do
      it { should be_directory }
    end

    describe file('/usr/share/elasticsearch/scripts') do
      it { should be_directory }
    end

    describe file("/etc/elasticsearch/#{instance}/scripts") do
      it { should be_symlink }
    end

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

        it 'uses the default data path' do
          json = JSON.parse(response.body)['nodes'].values.first
          expect(
            json['settings']['path']
          ).to include(
            'data' => "/var/lib/elasticsearch/#{instance}"
          )
        end
      end
    end
  end
end
