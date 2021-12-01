# frozen_string_literal: true

require 'spec_helper_rspec'

describe Puppet::Type.type(:elasticsearch_role).provider(:ruby) do
  describe 'instances' do
    it 'has an instance method' do
      expect(described_class).to respond_to :instances
    end

    context 'with no roles' do
      it 'returns no resources' do
        expect(described_class.parse("\n")).to eq([])
      end
    end

    context 'with one role' do
      it 'returns one resource' do
        expect(described_class.parse(%(
          admin:
            cluster: all
            indices:
              '*': all
        ))[0]).to eq(
          ensure: :present,
          name: 'admin',
          privileges: {
            'cluster' => 'all',
            'indices' => {
              '*' => 'all'
            }
          }
        )
      end
    end

    context 'with multiple roles' do
      it 'returns three resources' do
        expect(described_class.parse(%(
          admin:
            cluster: all
            indices:
              '*': all
          user:
            indices:
                '*': read
          power_user:
            cluster: monitor
            indices:
              '*': all
        )).length).to eq(3)
      end
    end
  end

  describe 'prefetch' do
    it 'has a prefetch method' do
      expect(described_class).to respond_to :prefetch
    end
  end
end
