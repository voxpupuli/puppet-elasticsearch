require 'spec_helper'

describe Puppet::Type.type(:elasticsearch_plugin) do

  let(:resource_name) { 'lmenezes/elasticsearch-kopf' }

  describe 'input validation' do

    it "should default to being installed" do
      plugin = described_class.new(:name => resource_name )
      expect(plugin.should(:ensure)).to eq(:present)
    end

    describe "when validating attributes" do
      [:name, :source, :url, :proxy].each do |param|
        it "should have a #{param} parameter" do
          expect(described_class.attrtype(param)).to eq(:param)
        end
      end

      it "should have an ensure property" do
        expect(described_class.attrtype(:ensure)).to eq(:property)
      end
    end

  end

end

describe Puppet::Type.type(:elasticsearch_plugin).provider(:plugin) do

  it 'should install a plugin' do
    resource = Puppet::Type.type(:elasticsearch_plugin).new(
      :name => "lmenezes/elasticsearch-kopf",
      :ensure => :present
    )
    allow(File).to receive(:open)
    provider = described_class.new(resource)
    allow(provider).to receive(:es_version).and_return '1.7.3'
    provider.expects(:plugin).with([
      'install',
      'lmenezes/elasticsearch-kopf'
    ])
    provider.create
  end

end
