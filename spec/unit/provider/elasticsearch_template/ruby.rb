require 'spec_helper'

describe Puppet::Type.type(:elasticsearch_template).provider(:ruby) do

  describe 'instances' do
    it 'should have an instance method' do
      expect(described_class).to respond_to :instances
    end
  end

end # of describe puppet type
