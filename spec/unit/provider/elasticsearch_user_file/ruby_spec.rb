# frozen_string_literal: true

require 'spec_helper_rspec'

describe Puppet::Type.type(:elasticsearch_user_file).provider(:ruby) do
  describe 'instances' do
    it 'has an instance method' do
      expect(described_class).to respond_to :instances
    end

    context 'without users' do
      it 'returns no resources' do
        expect(described_class.parse("\n")).to eq([])
      end
    end

    context 'with one user' do
      it 'returns one resource' do
        expect(described_class.parse(%(
          elastic:$2a$10$DddrTs0PS3qNknUTq0vpa.g.0JpU.jHDdlKp1xox1W5ZHX.w8Cc8C
        ).gsub(%r{^\s+}, ''))[0]).to eq(
          name: 'elastic',
          hashed_password: '$2a$10$DddrTs0PS3qNknUTq0vpa.g.0JpU.jHDdlKp1xox1W5ZHX.w8Cc8C',
          record_type: :ruby
        )
      end
    end

    context 'with multiple users' do
      it 'returns three resources' do
        expect(described_class.parse(%(

          admin:$2a$10$DddrTs0PS3qNknUTq0vpa.g.0JpU.jHDdlKp1xox1W5ZHX.w8Cc8C
          user:$2a$10$caYr8GhYeJ2Yo0yEhQhQvOjLSwt8Lm6MKQWx8WSnZ/L/IL5sGdQFu
          kibana:$2a$10$daYr8GhYeJ2Yo0yEhQhQvOjLSwt8Lm6MKQWx8WSnZ/L/IL5sGdQFu
        ).gsub(%r{^\s+}, '')).length).to eq(3)
      end
    end
  end

  describe 'prefetch' do
    it 'has a prefetch method' do
      expect(described_class).to respond_to :prefetch
    end
  end
end
