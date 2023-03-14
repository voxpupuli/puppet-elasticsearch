# frozen_string_literal: true

require_relative '../../helpers/unit/type/elasticsearch_rest_shared_examples'

describe Puppet::Type.type(:elasticsearch_component_template) do
  let(:resource_name) { 'test_template' }

  include_examples 'REST API types', 'component_template', :content

  describe 'template attribute validation' do
    it 'has a source parameter' do
      expect(described_class.attrtype(:source)).to eq(:param)
    end

    describe 'content and source validation' do
      it 'requires either "content" or "source"' do
        expect do
          described_class.new(
            name: resource_name,
            ensure: :present
          )
        end.to raise_error(Puppet::Error, %r{content.*or.*source.*required})
      end

      it 'fails with both defined' do
        expect do
          described_class.new(
            name: resource_name,
            content: {},
            source: 'puppet:///example.json'
          )
        end.to raise_error(Puppet::Error, %r{simultaneous})
      end

      it 'parses source paths into the content property' do
        file_stub = 'foo'.dup
        [
          Puppet::FileServing::Metadata,
          Puppet::FileServing::Content
        ].each do |klass|
          allow(klass).to receive(:indirection).
            and_return(Object)
        end
        allow(Object).to receive(:find).
          and_return(file_stub)
        allow(file_stub).to receive(:content).
          and_return('{"template": {"mappings": {"properties":{"dummy": {"type": "keyword"}}}}}')
        expect(described_class.new(
          name: resource_name,
          source: '/example.json'
        )[:content]).to include(
          'template' => {
            'mappings' => {
              'properties' => {
                'dummy' => {
                  'type' => 'keyword'
                }
              }
            }
          }
        )
      end

      # TODO?
      it 'qualifies settings' do
        expect(described_class.new(
          name: resource_name,
          content: {
            'template' => {
              'settings' => {
                'number_of_replicas' => '2',
                'index' => { 'number_of_shards' => '3' }
              }
            }
          }
        )[:content]).to eq(
          'template' => {
            'settings' => {
              'index' => {
                'number_of_replicas' => 2,
                'number_of_shards' => 3
              }
            }
          }
        )
      end

      it 'detects flat qualified index settings' do
        expect(described_class.new(
          name: resource_name,
          content: {
            'template' => {
              'settings' => {
                'number_of_replicas' => '2',
                'index.number_of_shards' => '3'
              }
            }
          }
        )[:content]).to eq(
          'template' => {
            'settings' => {
              'index' => {
                'number_of_replicas' => 2,
                'number_of_shards' => 3
              }
            }
          }
        )
      end
    end
  end

  describe 'insync?' do
    # Although users can pass the type a hash structure with any sort of values
    # - string, integer, or other native datatype - the Elasticsearch API
    # normalizes all values to strings. In order to verify that the type does
    # not incorrectly detect changes when values may be in string form, we take
    # an example template and force all values to strings to mimic what
    # Elasticsearch does.
    it 'is idempotent' do
      def deep_stringify(obj)
        if obj.is_a? Array
          obj.map { |element| deep_stringify(element) }
        elsif obj.is_a? Hash
          obj.merge(obj) { |_key, val| deep_stringify(val) }
        elsif [true, false].include? obj
          obj
        else
          obj.to_s
        end
      end
      json = JSON.parse(File.read('spec/fixtures/templates/component.json'))

      is_template = described_class.new(
        name: resource_name,
        ensure: 'present',
        content: json
      ).property(:content)
      should_template = described_class.new(
        name: resource_name,
        ensure: 'present',
        content: deep_stringify(json)
      ).property(:content).should

      expect(is_template).to be_insync(should_template)
    end
  end
end
