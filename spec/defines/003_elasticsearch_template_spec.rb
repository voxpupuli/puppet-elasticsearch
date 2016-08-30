require 'spec_helper'

describe 'elasticsearch::template', :type => 'define' do

  let :facts do {
    :operatingsystem => 'CentOS',
    :kernel => 'Linux',
    :osfamily => 'RedHat',
    :operatingsystemmajrelease => '6',
    :scenario => '',
    :common => ''
  } end

  let(:title) { 'foo' }
  let(:pre_condition) { <<-EOS
    class { 'elasticsearch' : }
  EOS
  }

  describe 'parameter validation' do
    [:api_ca_file, :api_ca_path].each do |param|
      let :params do {
        :ensure => 'present',
        :content => '{}',
        param => 'foo/cert'
      } end

      it { is_expected.to compile
        .and_raise_error(/absolute path/) }
    end
  end


  describe 'template from source' do

    let :params do {
      :ensure => 'present',
      :source => 'puppet:///path/to/foo.json',
      :api_protocol => 'https',
      :api_host => '127.0.0.1',
      :api_port => 9201,
      :api_timeout => 11,
      :api_basic_auth_username => 'elastic',
      :api_basic_auth_password => 'password',
      :validate_tls => false
    } end

    it { should contain_elasticsearch__template('foo') }
    it { should contain_es_instance_conn_validator('foo-template')
      .that_comes_before('Elasticsearch_template[foo]') }
    it { should contain_elasticsearch_template('foo').with(
      :ensure => 'present',
      :source => 'puppet:///path/to/foo.json',
      :protocol => 'https',
      :host => '127.0.0.1',
      :port => 9201,
      :timeout => 11,
      :username => 'elastic',
      :password => 'password',
      :validate_tls => false
    ) }
  end

  describe 'class parameter inheritance' do

    let :params do {
      :ensure => 'present',
      :content => '{}',
    } end
    let(:pre_condition) { <<-EOS
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
    }

    it { should contain_elasticsearch_template('foo').with(
      :ensure => 'present',
      :content => '{}',
      :protocol => 'https',
      :host => '127.0.0.1',
      :port => 9201,
      :timeout => 11,
      :username => 'elastic',
      :password => 'password',
      :ca_file => '/foo/bar.pem',
      :ca_path => '/foo/',
      :validate_tls => false
    ) }
  end

  describe 'template from file' do

    let :params do {
      :ensure => 'present',
      :file => '/path/to/other_foo.json',
    } end

    it { should contain_elasticsearch_template('foo').with(
      :ensure => 'present',
      :source => '/path/to/other_foo.json',
    ) }
  end

  describe 'template deletion' do

    let :params do {
      :ensure => 'absent',
    } end

    it { should contain_elasticsearch_template('foo').with(
      :ensure => 'absent'
    ) }
  end

end
