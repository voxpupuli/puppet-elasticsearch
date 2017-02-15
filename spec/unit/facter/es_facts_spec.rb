require 'json'
require 'spec_helper'
require 'webmock/rspec'
require 'yaml'

def es_uuid
  [('a'..'b'), ('A'..'Z'), (0..9)].flat_map(&:to_a).sample(22).join
end

# rubocop:disable Metrics/BlockLength
describe 'Facter::Util::Fact' do
  before do
    allow(Facter.fact(:kernel)).to receive(:value).and_return('Linux')
  end

  let(:cluster_name) { 'elasticsearch' }
  let(:cluster_uuid) { es_uuid }
  let(:config) { { 'http.port' => '9201' } }
  let(:mlockall) { false }
  let(:node_id) { es_uuid }
  let(:node_name) { 'centos-7-x64-es-01' }
  let(:version) { '5.2.1' }

  let(:node_response) do
    JSON.dump(
      'cluster_name' => 'elasticsearch',
      'nodes' => {
        node_id => {
          'name' => 'centos-7-x64-es-01',
          'plugins' => [],
          'process' => {
            'mlockall' => mlockall
          }
        }
      }
    )
  end

  let(:root_response) do
    JSON.dump(
      'name' => node_name,
      'cluster_name' => cluster_name,
      'cluster_uuid' => cluster_uuid,
      'version' => {
        'number' => version,
        'build_hash' => 'db0d481',
        'build_date' => '2017-02-09T22:05:32.386Z',
        'build_snapshot' => false,
        'lucene_version' => '6.4.1'
      },
      'tagline' => 'You Know, for Search'
    )
  end

  describe 'elasticsearch' do
    it 'discovers REST facts' do
      allow(File).to receive(:directory?).and_call_original
      allow(File).to receive(:directory?).with('/etc/elasticsearch')
        .and_return(true)
      allow(Dir).to receive(:foreach)
        .and_yield('.').and_yield('..').and_yield('es-01').and_yield('scripts')
      allow(File).to receive(:exists?).and_call_original
      allow(File).to receive(:exists?)
        .with('/etc/elasticsearch/es-01/elasticsearch.yml')
        .and_return(true)
      allow(YAML).to receive(:load_file)
        .with('/etc/elasticsearch/es-01/elasticsearch.yml')
        .and_return(config)
      stub_request(:get, 'http://localhost:9201')
        .to_return(
          :status => 200,
          :body => root_response
        )
      stub_request(:get, "http://localhost:9201/_nodes/#{node_name}")
        .to_return(
          :status => 200,
          :body => node_response
        )

      expect(Facter.fact(:elasticsearch_9201_cluster_name).value)
        .to eql(cluster_name)
      expect(Facter.fact(:elasticsearch_9201_mlockall).value).to eql(mlockall)
      expect(Facter.fact(:elasticsearch_9201_name).value).to eql(node_name)
      expect(Facter.fact(:elasticsearch_9201_node_id).value).to eql(node_id)
      expect(Facter.fact(:elasticsearch_9201_plugins).value).to be_empty
      expect(Facter.fact(:elasticsearch_9201_version).value).to eql(version)
      expect(Facter.fact(:elasticsearch_ports).value).to eql('9201')
    end
  end
end
