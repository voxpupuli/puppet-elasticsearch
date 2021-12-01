# frozen_string_literal: true

require 'spec_helper_rspec'

describe Puppet::Type.type(:elasticsearch_role_mapping) do
  let(:resource_name) { 'elastic_role' }

  describe 'when validating attributes' do
    [:name].each do |param|
      it "has a #{param} parameter" do
        expect(described_class.attrtype(param)).to eq(:param)
      end
    end

    %i[ensure mappings].each do |prop|
      it "has a #{prop} property" do
        expect(described_class.attrtype(prop)).to eq(:property)
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

    describe 'name' do
      it 'rejects long role names' do
        expect do
          described_class.new(
            name: 'a' * 41
          )
        end.to raise_error(
          Puppet::ResourceError,
          %r{valid values}i
        )
      end

      it 'rejects invalid role characters' do
        ['@foobar', '0foobar'].each do |role|
          expect do
            described_class.new(
              name: role
            )
          end.to raise_error(
            Puppet::ResourceError,
            %r{valid values}i
          )
        end
      end
    end
  end
end
