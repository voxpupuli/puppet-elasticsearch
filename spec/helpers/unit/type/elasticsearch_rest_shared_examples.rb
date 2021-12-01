# frozen_string_literal: true

require 'spec_helper_rspec'

shared_examples 'REST API types' do |resource_type, meta_property|
  let(:default_params) do
    { meta_property => {} }
  end

  describe "attribute validation for #{resource_type}s" do
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
    ].each do |param|
      it "has a #{param} parameter" do
        expect(described_class.attrtype(param)).to eq(:param)
      end
    end

    [
      :ensure,
      meta_property
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

    describe meta_property.to_s do
      it 'rejects non-hash values' do
        expect do
          described_class.new(
            :name => resource_name,
            meta_property => '{"foo":}'
          )
        end.to raise_error(Puppet::Error, %r{hash expected}i)

        expect do
          described_class.new(
            :name => resource_name,
            meta_property => 0
          )
        end.to raise_error(Puppet::Error, %r{hash expected}i)

        expect do
          described_class.new(
            default_params.merge(
              name: resource_name
            )
          )
        end.not_to raise_error
      end

      it 'parses PSON-like values for certain types' do
        expect(described_class.new(
          :name => resource_name,
          meta_property => { 'key' => { 'value' => '0', 'other' => true } }
        )[meta_property]).to include(
          'key' => { 'value' => 0, 'other' => true }
        )
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
