# frozen_string_literal: true

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', 'lib'))

require 'spec_helper_rspec'
require 'puppet_x/elastic/hash'

describe Puppet_X::Elastic::SortedHash do
  subject { { 'foo' => 1, 'bar' => 2 } }

  describe 'each_pair' do
    it { is_expected.to respond_to :each_pair }

    it 'yields values' do
      expect { |b| subject.each_pair(&b) }.to yield_control.exactly(2).times
    end

    it 'returns an Enumerator if not passed a block' do
      expect(subject.each_pair).to be_an_instance_of(Enumerator)
    end

    it 'returns values' do
      subject.each_pair.map { |k, v| [k, v] }.should == subject.to_a
    end
  end
end
