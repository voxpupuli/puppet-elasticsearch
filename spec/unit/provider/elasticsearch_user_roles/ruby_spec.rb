# frozen_string_literal: true

require 'spec_helper_rspec'

describe Puppet::Type.type(:elasticsearch_user_roles).
  provider(:ruby) do
  describe 'instances' do
    it 'has an instance method' do
      expect(described_class).to respond_to :instances
    end

    context 'without roles' do
      it 'returns no resources' do
        expect(described_class.parse("\n")).to eq([])
      end
    end

    context 'with one user' do
      it 'returns one resource' do
        expect(described_class.parse(%(
          admin:elastic
          power_user:elastic
        ))[0]).to eq(
          name: 'elastic',
          roles: %w[admin power_user]
        )
      end
    end

    context 'with multiple users' do
      it 'returns three resources' do
        expect(described_class.parse(%(
          admin:elastic
          logstash:user
          kibana:kibana
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
