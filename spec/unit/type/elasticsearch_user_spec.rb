require 'spec_helper_rspec'

[
  :elasticsearch_user,
  :elasticsearch_user_file
].each do |described_type|
  describe Puppet::Type.type(described_type) do
    let(:resource_name) { 'elastic' }

    describe 'when validating attributes' do
      [:name, :configdir].each do |param|
        it "should have a #{param} parameter" do
          expect(described_class.attrtype(param)).to eq(:param)
        end
      end

      [:ensure].each do |prop|
        it "should have a #{prop} property" do
          expect(described_class.attrtype(prop)).to eq(:property)
        end
      end

      describe 'namevar validation' do
        it 'should have :name as its namevar' do
          expect(described_class.key_attributes).to eq([:name])
        end
      end
    end # of describe when validating attributes

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
      end

      {
        :hashed_password => :property,
        :password => :param
      }.each_pair do |attribute, type|
        next unless described_class.respond_to? attribute

        describe attribute.to_s do
          it "should have a #{attrtype} #{type}" do
            expect(described_class.attrtype(attribute)).to eq(type)
          end
        end

        next unless attribute == :password
        it 'should reject short passwords' do
          expect { described_class.new(
            :name => resource_name,
            :password => 'foo'
          ) }.to raise_error(Puppet::Error, /must be at least/)
        end
      end
    end # of describing when validing values
  end # of describe Puppet::Type
end
