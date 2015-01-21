require 'spec_helper'
require 'webmock/rspec'
include WebMock::API

stub_request(:get, "http://localhost:9200/").with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).to_return(:status => 200, :body => File.read(File.join(fixture_path, 'facts/facts_url1.json') ), :headers => {})
stub_request(:get, "http://localhost:9200/_nodes/Warlock").with(:headers => {'Accept'=>'*/*', 'User-Agent'=>'Ruby'}).to_return(:status => 200, :body => File.read(File.join(fixture_path, 'facts/facts_url2.json') ))

require 'lib/facter/es_facts'

describe "ES facts" do

  describe "main" do
    it "elasticsearch_ports" do 
      expect(Facter.fact(:elasticsearch_ports).value).to eq("9200")
    end

  end

  describe "instance" do

    it "elasticsearch_9200_name" do 
      expect(Facter.fact(:elasticsearch_9200_name).value).to eq("Warlock")
    end

    it "elasticsearch_9200_version" do 
      expect(Facter.fact(:elasticsearch_9200_version).value).to eq("1.4.2")
    end

    it "elasticsearch_9200_cluster_name" do 
      expect(Facter.fact(:elasticsearch_9200_cluster_name).value).to eq("elasticsearch")
    end

    it "elasticsearch_9200_node_id" do 
      expect(Facter.fact(:elasticsearch_9200_node_id).value).to eq("yQAWBO3FS8CupZnSvAVziQ")
    end
    
    it "elasticsearch_9200_mlockall" do 
      expect(Facter.fact(:elasticsearch_9200_mlockall).value).to be_falsy
    end
    
    it "elasticsearch_9200_plugins" do 
      expect(Facter.fact(:elasticsearch_9200_plugins).value).to eq("kopf")
    end
 
    describe "plugin kopf" do
      it "elasticsearch_9200_plugin_kopf_version" do 
        expect(Facter.fact(:elasticsearch_9200_plugin_kopf_version).value).to eq("1.4.3")
      end
      
      it "elasticsearch_9200_plugin_kopf_description" do 
        expect(Facter.fact(:elasticsearch_9200_plugin_kopf_description).value).to eq("kopf - simple web administration tool for ElasticSearch")
      end
      
      it "elasticsearch_9200_plugin_kopf_url" do 
        expect(Facter.fact(:elasticsearch_9200_plugin_kopf_url).value).to eq("/_plugin/kopf/")
      end

      it "elasticsearch_9200_plugin_kopf_jvm" do 
        expect(Facter.fact(:elasticsearch_9200_plugin_kopf_jvm).value).to be_falsy
      end
      
      it "elasticsearch_9200_plugin_kopf_site" do 
        expect(Facter.fact(:elasticsearch_9200_plugin_kopf_site).value).to be_truthy
      end

    end
  end

end
