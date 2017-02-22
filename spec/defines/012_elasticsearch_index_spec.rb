require 'spec_helper'

# rubocop:disable Metrics/BlockLength
describe 'elasticsearch::index', :type => 'define' do
  let :facts do
    {
      :operatingsystem => 'CentOS',
      :kernel => 'Linux',
      :osfamily => 'RedHat',
      :operatingsystemmajrelease => '6',
      :scenario => '',
      :common => ''
    }
  end

  let(:title) { 'test-index' }
  let(:pre_condition) do
    'class { "elasticsearch" : }'
  end

  describe 'parameter validation' do
    [:api_ca_file, :api_ca_path].each do |param|
      let :params do
        {
          :ensure => 'present',
          param => 'foo/cert'
        }
      end

      it 'validates cert paths' do
        is_expected.to compile.and_raise_error(/absolute path/)
      end
    end
  end

  describe 'class parameter inheritance' do
    let :params do
      {
        :ensure => 'present'
      }
    end
    let(:pre_condition) do
      <<-EOS
        class { 'elasticsearch' :
          api_protocol => 'https',
          api_host => '127.0.0.1',
          api_port => 9201,
          api_timeout => 11,
          api_basic_auth_username => 'elastic',
          api_basic_auth_password => 'password',
          api_ca_file => '/foo/bar.pem',
          api_ca_path => '/foo/',
          validate_tls => false,
        }
      EOS
    end

    it do
      should contain_elasticsearch__index(title)
      should contain_es_instance_conn_validator("#{title}-index-conn-validator")
        .that_comes_before("elasticsearch_index[#{title}]")
      should contain_elasticsearch_index(title).with(
        :ensure => 'present',
        :settings => {},
        :protocol => 'https',
        :host => '127.0.0.1',
        :port => 9201,
        :timeout => 11,
        :username => 'elastic',
        :password => 'password',
        :ca_file => '/foo/bar.pem',
        :ca_path => '/foo/',
        :validate_tls => false
      )
    end
  end

  describe 'index deletion' do
    let :params do
      {
        :ensure => 'absent'
      }
    end

    it 'removes indices' do
      should contain_elasticsearch_index(title).with(:ensure => 'absent')
    end
  end
end
