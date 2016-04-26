require 'spec_helper'

describe Puppet::Type.type(:elasticsearch_shield_user).provider(:file) do

  on_supported_os.each do |os, facts|

    let(:facts) { facts }

    describe 'instances' do
      it 'should have an instance method' do
        expect(described_class).to respond_to :instances
      end
    end

    describe 'prefetch' do
      it 'should have a prefetch method' do
        expect(described_class).to respond_to :prefetch
      end
    end
  end # of on_supported_os.each
end # of describe puppet type
