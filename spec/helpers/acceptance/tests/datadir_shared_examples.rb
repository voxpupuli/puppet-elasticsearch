require 'json'
require 'helpers/acceptance/tests/manifest_shared_examples'

shared_examples 'datadir directory validation' do |instances, datapaths|
  include_examples(
    'manifest application',
    instances
  )

  instances.each_pair do |instance, config|
    describe file("/etc/elasticsearch/#{instance}/elasticsearch.yml") do
      it { should be_file }
      datapaths.each do |datapath|
        it { should contain datapath }
      end
    end

    datapaths.each do |datapath|
      describe file(datapath) do
        it { should be_directory }
      end
    end

    describe port(config['config']['http.port']) do
      it 'open', :with_retries do
        should be_listening
      end
    end

    describe server :container do
      describe http(
        "http://localhost:#{config['config']['http.port']}/_nodes/_local"
      ) do
        it 'uses a custom data path' do
          json = JSON.parse(response.body)['nodes'].values.first
          expect(
            json['settings']['path']['data']
          ).to((datapaths.one? and v[:elasticsearch_major_version] <= 2) ? eq(datapaths.first) : contain_exactly(*datapaths))
        end
      end
    end
  end
end

shared_examples 'datadir acceptance tests' do
  describe 'elasticsearch::datadir' do
    let(:manifest_class_parameters) { 'restart_on_change => true' }

    instances =
      {
        'es-01' => {
          'config' => {
            'http.port' => 9200
          }
        }
      }

    context 'single path from class', :with_cleanup do
      let(:manifest_class_parameters) do
        <<-MANIFEST
          datadir => '/var/lib/elasticsearch-data',
          restart_on_change => true,
        MANIFEST
      end
      include_examples 'datadir directory validation', instances, ['/var/lib/elasticsearch-data/es-01']
    end

    context 'single path from instance', :with_cleanup do
      let(:manifest_instance_parameters) { "datadir => '/var/lib/elasticsearch-data/1'" }
      include_examples 'datadir directory validation', instances, ['/var/lib/elasticsearch-data/1']
    end

    context 'multiple paths from class', :with_cleanup do
      let(:manifest_class_parameters) do
        <<-MANIFEST
          datadir => [
            '/var/lib/elasticsearch-01',
            '/var/lib/elasticsearch-02'
          ],
          restart_on_change => true,
        MANIFEST
      end
      include_examples 'datadir directory validation',
                       instances,
                       ['/var/lib/elasticsearch-01/es-01', '/var/lib/elasticsearch-02/es-01']
    end

    context 'multiple paths from instance', :with_cleanup do
      let(:manifest_instance_parameters) do
        <<-MANIFEST
          datadir => [
            '/var/lib/elasticsearch-data/2',
            '/var/lib/elasticsearch-data/3'
          ]
        MANIFEST
      end
      include_examples 'datadir directory validation',
                       instances,
                       ['/var/lib/elasticsearch-data/2', '/var/lib/elasticsearch-data/3']
    end
  end
end
