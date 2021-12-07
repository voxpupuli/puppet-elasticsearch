# frozen_string_literal: true

require_relative '../../helpers/unit/type/elasticsearch_rest_shared_examples'

describe Puppet::Type.type(:elasticsearch_snapshot_repository) do
  let(:resource_name) { 'test_repository' }

  let(:default_params) do
    {
      location: '/backup'
    }
  end

  describe 'attribute validation for elasticsearch_snapshot_repository' do
    %i[
      name
      host
      port
      protocol
      validate_tls
      ca_file
      ca_path
      timeout
      username
      password
      type
    ].each do |param|
      it "has a #{param} parameter" do
        expect(described_class.attrtype(param)).to eq(:param)
      end
    end

    %i[
      ensure
      compress
      location
      chunk_size
      max_restore_rate
      max_snapshot_rate
    ].each do |prop|
      it "has a #{prop} property" do
        expect(described_class.attrtype(prop)).to eq(:property)
      end
    end

    describe 'namevar validation' do
      it 'has :name as its namevar' do
        expect(described_class.key_attributes).to eq([:name])
      end
    end

    describe 'ensure' do
      it 'supports present as a value for ensure' do
        expect do
          described_class.new(
            default_params.merge(
              name: resource_name,
              ensure: :present
            )
          )
        end.not_to raise_error
      end

      it 'supports absent as a value for ensure' do
        expect do
          described_class.new(
            default_params.merge(
              name: resource_name,
              ensure: :absent
            )
          )
        end.not_to raise_error
      end

      it 'does not support other values' do
        expect do
          described_class.new(
            default_params.merge(
              name: resource_name,
              ensure: :foo
            )
          )
        end.to raise_error(Puppet::Error, %r{Invalid value})
      end
    end

    describe 'location' do
      it 'is required' do
        expect do
          described_class.new(
            name: resource_name
          )
        end.to raise_error(Puppet::Error, %r{Location is required.})
      end
    end

    describe 'host' do
      it 'accepts IP addresses' do
        expect do
          described_class.new(
            default_params.merge(
              name: resource_name,
              host: '127.0.0.1'
            )
          )
        end.not_to raise_error
      end
    end

    describe 'port' do
      [-1, 0, 70_000, 'foo'].each do |value|
        it "rejects invalid port value #{value}" do
          expect do
            described_class.new(
              default_params.merge(
                name: resource_name,
                port: value
              )
            )
          end.to raise_error(Puppet::Error, %r{invalid port}i)
        end
      end
    end

    describe 'validate_tls' do
      [-1, 0, {}, [], 'foo'].each do |value|
        it "rejects invalid ssl_verify value #{value}" do
          expect do
            described_class.new(
              default_params.merge(
                name: resource_name,
                validate_tls: value
              )
            )
          end.to raise_error(Puppet::Error, %r{invalid value}i)
        end
      end

      [true, false, 'true', 'false', 'yes', 'no'].each do |value|
        it "accepts validate_tls value #{value}" do
          expect do
            described_class.new(
              default_params.merge(
                name: resource_name,
                validate_tls: value
              )
            )
          end.not_to raise_error
        end
      end
    end

    describe 'timeout' do
      it 'rejects string values' do
        expect do
          described_class.new(
            default_params.merge(
              name: resource_name,
              timeout: 'foo'
            )
          )
        end.to raise_error(Puppet::Error, %r{must be a})
      end

      it 'rejects negative integers' do
        expect do
          described_class.new(
            default_params.merge(
              name: resource_name,
              timeout: -10
            )
          )
        end.to raise_error(Puppet::Error, %r{must be a})
      end

      it 'accepts integers' do
        expect do
          described_class.new(
            default_params.merge(
              name: resource_name,
              timeout: 10
            )
          )
        end.not_to raise_error
      end

      it 'accepts quoted integers' do
        expect do
          described_class.new(
            default_params.merge(
              name: resource_name,
              timeout: '10'
            )
          )
        end.not_to raise_error
      end
    end
  end
end
