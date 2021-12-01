# frozen_string_literal: true

require 'spec_helper_rspec'

describe Puppet::Type.type(:elasticsearch_user_roles) do
  let(:resource_name) { 'elastic' }

  describe 'when validating attributes' do
    [:name].each do |param|
      it "has a #{param} parameter" do
        expect(described_class.attrtype(param)).to eq(:param)
      end
    end

    %i[ensure roles].each do |prop|
      it "has a #{prop} property" do
        expect(described_class.attrtype(prop)).to eq(:property)
      end
    end

    describe 'namevar validation' do
      it 'has :name as its namevar' do
        expect(described_class.key_attributes).to eq([:name])
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
  end
end
