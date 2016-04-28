require 'spec_helper'

describe 'elasticsearch::shield::role' do

  let(:title) { 'elastic_role' }

  context 'with an invalid role name' do
    context 'too long' do
      let(:title) { 'A'*31 }
      it { should raise_error(Puppet::Error, /expected length/i) }
    end
  end

  context 'with default parameters' do

    let(:params) do
      {
        :privileges => {
          'cluster' => '*'
        }
      }
    end

    it { should contain_elasticsearch_shield_role('elastic_role') }
  end
end
