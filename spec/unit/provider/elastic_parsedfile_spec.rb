# frozen_string_literal: true

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', 'lib'))

require 'spec_helper_rspec'
require 'puppet/provider/elastic_parsedfile'

describe Puppet::Provider::ElasticParsedFile do
  subject do
    described_class.tap do |o|
      o.instance_eval { @metadata = :metadata }
    end
  end

  it { is_expected.to respond_to :default_target }
  it { is_expected.to respond_to :xpack_config }

  context 'when there is no default_target' do
    # describe 'default_target' do
    #   it 'returns a single whitespace' do
    #     expect(described_class.default_target).to(eq(' '))
    #   end
    # end

    describe 'xpack_config' do
      value = 'somefile'
      result = '/etc/elasticsearch/somefile'

      it 'fails when no value is given' do
        expect { described_class.xpack_config }.to raise_error(ArgumentError)
      end

      it 'defines default_target when given value' do
        expect(described_class.xpack_config(value)).to(eq(result))
        expect(described_class.instance_variable_get(:@default_target)).to(eq(result))
      end
    end
  end

  context 'whene there is a default_target' do
    describe 'xpack_config' do
      default_target = '/etc/elasticsearch/somefile'
      value = 'otherfile'
      described_class.instance_variable_set(:@default_target, default_target)

      it 'fails when no value is given' do
        expect { described_class.xpack_config }.to raise_error(ArgumentError)
      end

      it 'is idempotent' do
        expect(described_class.xpack_config('somefile')).to(eq(default_target))
      end

      it 'still returns the previously defined target when a new value is given' do
        expect(described_class.xpack_config(value)).to(eq(default_target))
      end
    end
  end
end
