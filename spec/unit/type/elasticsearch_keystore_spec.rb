# frozen_string_literal: true

require 'spec_helper_rspec'

describe Puppet::Type.type(:elasticsearch_keystore) do
  let(:resource_name) { 'es-01' }

  describe 'validating attributes' do
    %i[configdir instance purge].each do |param|
      it "has a `#{param}` parameter" do
        expect(described_class.attrtype(param)).to eq(:param)
      end
    end

    %i[ensure settings].each do |prop|
      it "has a #{prop} property" do
        expect(described_class.attrtype(prop)).to eq(:property)
      end
    end

    describe 'namevar validation' do
      it 'has :instance as its namevar' do
        expect(described_class.key_attributes).to eq([:instance])
      end
    end
  end

  describe 'when validating values' do
    describe 'ensure' do
      it 'supports present as a value for ensure' do
        expect do
          described_class.new(
            name: resource_name,
            ensure: :present
          )
        end.not_to raise_error
      end

      it 'supports absent as a value for ensure' do
        expect do
          described_class.new(
            name: resource_name,
            ensure: :absent
          )
        end.not_to raise_error
      end

      it 'does not support other values' do
        expect do
          described_class.new(
            name: resource_name,
            ensure: :foo
          )
        end.to raise_error(Puppet::Error, %r{Invalid value})
      end
    end

    describe 'settings' do
      [{ 'node.name' => 'foo' }, ['node.name', 'node.data']].each do |setting|
        it "accepts #{setting.class}s" do
          expect do
            described_class.new(
              name: resource_name,
              settings: setting
            )
          end.not_to raise_error
        end
      end

      describe 'insync' do
        it 'only checks lists or hash key membership' do
          expect(described_class.new(
            name: resource_name,
            settings: { 'node.name' => 'foo', 'node.data' => true }
          ).property(:settings).insync?(
            %w[node.name node.data]
          )).to be true
        end

        context 'purge' do
          it 'defaults to not purge values' do
            expect(described_class.new(
              name: resource_name,
              settings: { 'node.name' => 'foo', 'node.data' => true }
            ).property(:settings).insync?(
              %w[node.name node.data node.attr.rack]
            )).to be true
          end

          it 'respects the purge parameter' do
            expect(described_class.new(
              name: resource_name,
              settings: { 'node.name' => 'foo', 'node.data' => true },
              purge: true
            ).property(:settings).insync?(
              %w[node.name node.data node.attr.rack]
            )).to be false
          end
        end
      end
    end
  end
end
