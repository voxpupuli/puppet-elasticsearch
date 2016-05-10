require 'spec_helper'

describe Puppet::Type.type(:elasticsearch_shield_user).provider(:esusers) do

  on_supported_os.each do |os, facts|

    let(:facts) { facts }

    describe 'instances' do
      it 'should have an instance method' do
        expect(described_class).to respond_to :instances
      end

      context 'without roles' do
        it 'should return no resources' do
          expect(described_class.parse("\n")).to eq(0)
        end
      end

      context 'with one user' do
        it 'should return one resource' do
          expect(described_class.parse(%q{
            admin:elastic
            power_user:elastic
          })[0]).to eq({
            :ensure => :present,
            :name => 'elastic',
            :roles => ['admin', 'power_user'],
            :provider => :parsed,
          })
        end
      end

      context 'with multiple users' do
        it 'should return three resources' do
          expect(described_class.parse(%q{
            admin:elastic
            logstash:user
            kibana:kibana
          }).length).to eq(3)
        end
      end
    end # of describe instances

    describe 'prefetch' do
      it 'should have a prefetch method' do
        expect(described_class).to respond_to :prefetch
      end
    end
  end # of on_supported_os.each
end # of describe puppet type
