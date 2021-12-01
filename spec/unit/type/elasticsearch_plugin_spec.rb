# frozen_string_literal: true

require 'spec_helper_rspec'

describe Puppet::Type.type(:elasticsearch_plugin) do
  let(:resource_name) { 'lmenezes/elasticsearch-kopf' }

  describe 'input validation' do
    describe 'when validating attributes' do
      %i[configdir java_opts java_home name source url proxy].each do |param|
        it "has a #{param} parameter" do
          expect(described_class.attrtype(param)).to eq(:param)
        end
      end

      it 'has an ensure property' do
        expect(described_class.attrtype(:ensure)).to eq(:property)
      end
    end
  end
end
