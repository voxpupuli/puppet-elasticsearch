# frozen_string_literal: true

require 'spec_helper_rspec'

describe Puppet::Type.type(:elasticsearch_user).provider(:ruby) do
  describe 'instances' do
    it 'has an instance method' do
      expect(described_class).to respond_to :instances
    end

    context 'without users' do
      it 'returns no resources' do
        allow(described_class).to receive(:command_with_path).with('list').and_return(
          'No users found'
        )

        expect(described_class.instances.size).to eq(0)
        expect(described_class).to have_received(:command_with_path).with('list')
      end
    end

    context 'with one user' do
      it 'returns one resource' do
        allow(described_class).to receive(:command_with_path).with('list').and_return(
          'elastic        : admin*,power_user'
        )

        expect(described_class.instances[0].instance_variable_get(
                 '@property_hash'
               )).to eq(
                 ensure: :present,
                 name: 'elastic',
                 provider: :ruby
               )
        expect(described_class).to have_received(:command_with_path).with('list')
      end
    end

    context 'with multiple users' do
      it 'returns three resources' do
        allow(described_class).to receive(
          :command_with_path
        ).with('list').and_return(
          <<-EOL
            elastic        : admin*
            logstash       : user
            kibana         : kibana
          EOL
        )

        expect(described_class.instances.length).to eq(3)

        expect(described_class).to have_received(
          :command_with_path
        ).with('list')
      end
    end
  end

  describe 'prefetch' do
    it 'has a prefetch method' do
      expect(described_class).to respond_to :prefetch
    end
  end
end
