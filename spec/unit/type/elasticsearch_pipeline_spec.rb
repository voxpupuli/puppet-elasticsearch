require 'spec_helper'

require_relative 'elasticsearch_rest_shared_examples'

# rubocop:disable Metrics/BlockLength
describe Puppet::Type.type(:elasticsearch_pipeline) do
  let(:resource_name) { 'test_pipeline' }
  let(:default_params) do
    {}
  end

  include_examples 'REST API types', 'pipeline'

  describe 'pipeline attribute validation' do
    [
      :description,
      :processors
    ].each do |property|
      it "should have a #{property} property" do
        expect(described_class.attrtype(property)).to eq(:property)
      end
    end

    describe 'description' do
      [0, {}].each do |bad_value|
        it "should reject non-string value #{bad_value}" do
          expect do
            described_class.new(
              :name => resource_name,
              :description => bad_value
            )
          end.to raise_error(Puppet::Error, /string expected/i)
        end
      end

      ['', 'desc'].each do |good_value|
        it "accepts string #{good_value}" do
          expect do
            described_class.new(
              :name => resource_name,
              :description => good_value
            )
          end.not_to raise_error
        end
      end
    end

    describe 'processors' do
      ['{"foo":}', 0].each do |bad_value|
        it "should reject non-array value #{bad_value}" do
          expect do
            described_class.new(
              :name => resource_name,
              :processors => bad_value
            )
          end.to raise_error(Puppet::Error, /array expected/i)
        end
      end

      [
        [],
        [{
          'set' => {
            'field' => 'foo',
            'value' => 'bar'
          }
        }]
      ].each do |good_value|
        it "accepts array #{good_value}" do
          expect do
            described_class.new(
              :name => resource_name,
              :processors => [good_value]
            )
          end.not_to raise_error
        end
      end
    end
  end # of describing when validing values
end # of describe Puppet::Type
