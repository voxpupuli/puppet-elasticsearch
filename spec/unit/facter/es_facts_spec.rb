require 'spec_helper'
require 'webmock/rspec'

describe 'elasticsearch facts' do
  before(:each) do
    stub_request(:get, 'http://localhost:9200/')
      .with(:headers => { 'Accept' => '*/*', 'User-Agent' => 'Ruby' })
      .to_return(
        :status => 200,
        :body => File.read(
          File.join(
            fixture_path,
            'facts/Warlock-root.json'
          )
        )
      )

    stub_request(:get, 'http://localhost:9200/_nodes/Warlock')
      .with(:headers => { 'Accept' => '*/*', 'User-Agent' => 'Ruby' })
      .to_return(
        :status => 200,
        :body => File.read(
          File.join(
            fixture_path,
            'facts/Warlock-nodes.json'
          )
        )
      )

    allow(File)
      .to receive(:directory?)
      .and_return(true)

    allow(File)
      .to receive(:readable?)
      .and_return(true)

    allow(YAML)
      .to receive(:load_file)
      .with('/etc/elasticsearch/elasticsearch.yml', any_args)
      .and_return({})

    require 'lib/facter/es_facts'
  end

  describe 'elasticsearch_port' do
    it 'finds listening port' do
      expect(Facter.fact(:elasticsearch_port).value)
        .to eq('9200')
    end
  end

  describe 'instance' do
    it 'returns the node name' do
      expect(Facter.fact(:elasticsearch_name).value).to eq('Warlock')
    end

    it 'returns the node version' do
      expect(Facter.fact(:elasticsearch_version).value).to eq('1.4.2')
    end

    it 'returns the cluster name' do
      expect(Facter.fact(:elasticsearch_cluster_name).value)
        .to eq('elasticsearch')
    end

    it 'returns the node ID' do
      expect(Facter.fact(:elasticsearch_node_id).value)
        .to eq('yQAWBO3FS8CupZnSvAVziQ')
    end

    it 'returns the mlockall boolean' do
      expect(Facter.fact(:elasticsearch_mlockall).value).to be_falsy
    end

    it 'returns installed plugins' do
      expect(Facter.fact(:elasticsearch_plugins).value).to eq('kopf')
    end

    describe 'kopf plugin' do
      it 'returns the correct version' do
        expect(Facter.fact(:elasticsearch_plugin_kopf_version).value)
          .to eq('1.4.3')
      end

      it 'returns the correct description' do
        expect(Facter.fact(:elasticsearch_plugin_kopf_description).value)
          .to eq('kopf - simple web administration tool for ElasticSearch')
      end

      it 'returns the plugin URL' do
        expect(Facter.fact(:elasticsearch_plugin_kopf_url).value)
          .to eq('/_plugin/kopf/')
      end

      it 'returns the plugin JVM boolean' do
        expect(Facter.fact(:elasticsearch_plugin_kopf_jvm).value)
          .to be_falsy
      end

      it 'returns the plugin _site boolean' do
        expect(Facter.fact(:elasticsearch_plugin_kopf_site).value)
          .to be_truthy
      end
    end # of describe plugin
  end # of describe instance
end # of describe elasticsearch facts
