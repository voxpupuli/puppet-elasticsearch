require 'spec_helper'
require 'webmock/rspec'

describe Puppet::Type.type(:elasticsearch_template).provider(:ruby) do

  describe 'instances' do
    it 'should have an instance method' do
      expect(described_class).to respond_to :instances
    end
  end

  context 'with no templates' do
    before :all do
      stub_request(:get, 'http://localhost:9200/_template').
        to_return(
          :status => 200,
          :body => '{}'
      )
    end

    it 'returns an empty list' do
      expect(described_class.instances).to eq([])
    end
  end

  describe 'single templates' do
    before :all do
      stub_request(:get, 'http://localhost:9200/_template').
        to_return(
          :status => 200,
          :body => <<-EOS
            {
              "foobar1": {
                "aliases": {},
                "mappings": {},
                "order": 5,
                "settings": {},
                "template": "foobar1-*"
              },
              "foobar2": {
                "aliases": {},
                "mappings": {},
                "order": 1,
                "settings": {},
                "template": "foobar2-*"
              }
            }
          EOS
      )
    end

    it 'returns two templates' do
      expect(described_class.instances.map { |provider|
        provider.instance_variable_get(:@property_hash)
      }).to contain_exactly({
        :name => 'foobar1',
        :ensure => :present,
        :provider => :ruby,
        :content => {
          'aliases' => {},
          'mappings' => {},
          'settings' => {},
          'template' => 'foobar1-*',
          'order' => 5,
        }
      },{
        :name => 'foobar2',
        :ensure => :present,
        :provider => :ruby,
        :content => {
          'aliases' => {},
          'mappings' => {},
          'settings' => {},
          'template' => 'foobar2-*',
          'order' => 1,
        }
      })
    end
  end

end # of describe puppet type
