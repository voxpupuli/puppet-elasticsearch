# frozen_string_literal: true

require 'spec_helper_rspec'

%i[
  elasticsearch_user
  elasticsearch_user_file
].each do |described_type|
  describe Puppet::Type.type(described_type) do
    let(:resource_name) { 'elastic' }

    describe 'when validating attributes' do
      %i[name configdir].each do |param|
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

      {
        hashed_password: :property,
        password: :param
      }.each_pair do |attribute, type|
        next unless described_class.respond_to? attribute

        describe attribute.to_s do
          it "has a #{attrtype} #{type}" do
            expect(described_class.attrtype(attribute)).to eq(type)
          end
        end

        next unless attribute == :password

        it 'rejects short passwords' do
          expect do
            described_class.new(
              name: resource_name,
              password: 'foo'
            )
          end.to raise_error(Puppet::Error, %r{must be at least})
        end
      end
    end
  end
end
