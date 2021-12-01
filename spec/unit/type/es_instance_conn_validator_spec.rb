require_relative '../../helpers/unit/type/elasticsearch_rest_shared_examples'

describe Puppet::Type.type(:es_instance_conn_validator) do
  let(:resource_name) { 'conn-validator' }
  let(:conn_validator) do
    Puppet::Type.type(:es_instance_conn_validator)
                .new(name: resource_name)
  end

  describe 'when validating attributes' do
    [:name, :server, :port, :timeout, :sleep_interval].each do |param|
      it 'should have a #{param} parameter' do
        expect(described_class.attrtype(param)).to eq(:param)
      end
    end

    [:ensure].each do |prop|
      it 'should have a #{prop} property' do
        expect(described_class.attrtype(prop)).to eq(:property)
      end
    end

    describe 'namevar validation' do
      it 'should have :name as its namevar' do
        expect(described_class.key_attributes).to eq([:name])
      end
    end
  end # describe when validating attributes

  describe 'when validating values' do
    describe 'ensure' do
      it 'should support present as a value for ensure' do
        expect { described_class.new(
          :name => resource_name,
          :ensure => :present
        ) }.to_not raise_error
      end

      it 'should support absent as a value for ensure' do
        expect { described_class.new(
          :name => resource_name,
          :ensure => :absent
        ) }.to_not raise_error
      end

      it 'should not support other values' do
        expect { described_class.new(
          :name => resource_name,
          :ensure => :foo
        ) }.to raise_error(Puppet::Error, /Invalid value/)
      end
    end # describe 'ensure'

    describe 'timeout' do
      it 'should support a numerical value' do
        conn_validator[:timeout] = 120
        expect(conn_validator[:timeout]).to eq(120)
      end

      it 'should have a default value of 60' do
        expect(conn_validator[:timeout]).to eq(60)
      end

      it 'should not support a non-numeric value' do
        expect do
          conn_validator[:timeout] = 'string'
        end.to raise_error(Puppet::Error, /invalid value/)
      end
    end # describe 'timeout'

    describe 'sleep_interval' do
      it 'should support a numerical value' do
        conn_validator[:sleep_interval] = 120
        expect(conn_validator[:sleep_interval]).to eq(120)
      end

      it 'should have a default value of 10' do
        expect(conn_validator[:sleep_interval]).to eq(10)
      end

      it 'should not support a non-numeric value' do
        expect do
          conn_validator[:sleep_interval] = 'string'
        end.to raise_error(Puppet::Error, /invalid value/)
      end
    end # describe 'sleep_interval
  end # describe 'when valdating values'
end # of describe Puppet::Type
