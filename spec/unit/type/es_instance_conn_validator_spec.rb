# frozen_string_literal: true

require_relative '../../helpers/unit/type/elasticsearch_rest_shared_examples'

describe Puppet::Type.type(:es_instance_conn_validator) do
  let(:resource_name) { 'conn-validator' }
  let(:conn_validator) do
    Puppet::Type.type(:es_instance_conn_validator).
      new(name: resource_name)
  end

  describe 'when validating attributes' do
    %i[name server port timeout sleep_interval].each do |param|
      it "has a #{param} parameter" do
        expect(described_class.attrtype(param)).to eq(:param)
      end
    end

    [:ensure].each do |prop|
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

    describe 'timeout' do
      it 'supports a numerical value' do
        conn_validator[:timeout] = 120
        expect(conn_validator[:timeout]).to eq(120)
      end

      it 'has a default value of 60' do
        expect(conn_validator[:timeout]).to eq(60)
      end

      it 'does not support a non-numeric value' do
        expect do
          conn_validator[:timeout] = 'string'
        end.to raise_error(Puppet::Error, %r{invalid value})
      end
    end

    describe 'sleep_interval' do
      it 'supports a numerical value' do
        conn_validator[:sleep_interval] = 120
        expect(conn_validator[:sleep_interval]).to eq(120)
      end

      it 'has a default value of 10' do
        expect(conn_validator[:sleep_interval]).to eq(10)
      end

      it 'does not support a non-numeric value' do
        expect do
          conn_validator[:sleep_interval] = 'string'
        end.to raise_error(Puppet::Error, %r{invalid value})
      end
    end
  end
end
