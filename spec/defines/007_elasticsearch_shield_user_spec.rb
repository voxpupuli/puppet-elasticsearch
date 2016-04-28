require 'spec_helper'

describe 'elasticsearch::shield::user' do

  let(:title) { 'elastic' }

  context 'without a password' do
    it { should raise_error(Puppet::Error, /must pass password/i) }
  end

  context 'with default parameters' do

    let(:params) do
      {
        :password => 'foobar',
        :roles => ['monitor', 'user']
      }
    end

    it { should contain_elasticsearch_shield_user('elastic') }
  end
end
