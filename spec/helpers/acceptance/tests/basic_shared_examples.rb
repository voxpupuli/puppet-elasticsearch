require 'json'
require 'helpers/acceptance/tests/manifest_shared_examples'

shared_examples 'basic acceptance tests' do |instances|
  include_examples 'manifest application', instances

  describe package("elasticsearch#{v[:oss] ? '-oss' : ''}") do
    it { should be_installed }
  end

  %w[
    /usr/share/elasticsearch/templates_import
    /usr/share/elasticsearch/scripts
  ].each do |dir|
    describe file(dir) do
      it { should be_directory }
    end
  end

  instances.each do |instance, config|
    describe "resources for instance #{instance}" do
      describe service("elasticsearch-#{instance}") do
        it { send(config.empty? ? :should_not : :should, be_enabled) }
        it { send(config.empty? ? :should_not : :should, be_running) }
      end

      unless config.empty?
        describe file(pid_for(instance)) do
          it { should be_file }
          its(:content) { should match(/[0-9]+/) }
        end

        describe file("/etc/elasticsearch/#{instance}/elasticsearch.yml") do
          it { should be_file }
          it { should contain "name: #{config['config']['node.name']}" }
          it { should contain "/var/lib/elasticsearch/#{instance}" }
        end
      end

      unless config.empty?
        describe file("/var/lib/elasticsearch/#{instance}") do
          it { should be_directory }
        end

        describe port(config['config']['http.port']) do
          it 'open', :with_retries do
            should be_listening
          end
        end

        describe server :container do
          describe http("http://localhost:#{config['config']['http.port']}/_nodes/_local") do
            it 'serves requests', :with_retries do
              expect(response.status).to eq(200)
            end

            it 'uses the default data path', :with_retries do
              json = JSON.parse(response.body)['nodes'].values.first
              expected = "/var/lib/elasticsearch/#{instance}"
              expected = [expected] if v[:elasticsearch_major_version] > 2
              expect(
                json['settings']['path']
              ).to include(
                'data' => expected
              )
            end
          end
        end
      end
    end
  end
end
