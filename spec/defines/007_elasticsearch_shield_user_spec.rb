require 'spec_helper'

describe 'elasticsearch::shield::user' do

  let :facts do {
    :operatingsystem => 'CentOS',
    :kernel => 'Linux',
    :osfamily => 'RedHat',
    :operatingsystemmajrelease => '7',
    :scenario => '',
    :common => ''
  } end

  let(:title) { 'elastic' }

  let(:pre_condition) {%q{
    class { 'elasticsearch': }
    elasticsearch::instance { 'es-01': }
    elasticsearch::plugin { 'shield': instances => 'es-01' }
    elasticsearch::template { 'foo': content => {"foo" => "bar"} }
  }}

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

    it { should contain_elasticsearch__shield__user('elastic')
      .that_comes_before([
      'Elasticsearch::Template[foo]'
    ]).that_requires([
      'Elasticsearch::Plugin[shield]'
    ])}
    it { should contain_elasticsearch_shield_user('elastic') }
    it do
      should contain_elasticsearch_shield_user_roles('elastic').with(
        'ensure' => 'present',
        'roles'  => ['monitor', 'user']
      )
    end
  end
end
