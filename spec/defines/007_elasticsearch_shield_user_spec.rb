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

    it { should contain_elasticsearch__shield__user('elastic') }
    it { should contain_elasticsearch_shield_user('elastic') }
    it do
      should contain_elasticsearch_shield_user_roles('elastic').with(
        'ensure' => 'present',
        'roles'  => ['monitor', 'user']
      )
    end
  end
end
