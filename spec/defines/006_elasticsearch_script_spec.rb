require 'spec_helper'

describe 'elasticsearch::script', :type => 'define' do
  let :facts do {
    :operatingsystem => 'CentOS',
    :kernel => 'Linux',
    :osfamily => 'RedHat',
    :operatingsystemmajrelease => '6',
    :scenario => '',
    :common => ''
  } end

  let(:title) { 'foo' }
  let(:pre_condition) do
    %(
      class { "elasticsearch":
        config => {
          "node" => {"name" => "test" }
        }
      }
    )
  end

  describe 'adding script files' do
    let(:params) do {
      :ensure => 'present',
      :source => 'puppet:///path/to/foo.groovy'
    } end

    it { should contain_elasticsearch__script('foo') }
    it { should contain_file('/usr/share/elasticsearch/scripts/foo.groovy')
      .with(:source => 'puppet:///path/to/foo.groovy', :ensure => 'present') }
  end

  describe 'adding script directories' do
    let(:params) do {
      :ensure  => 'directory',
      :source  => 'puppet:///path/to/my_scripts',
      :recurse => 'remote'
    } end

    it { should contain_elasticsearch__script('foo') }
    it { should contain_file(
      '/usr/share/elasticsearch/scripts/my_scripts'
    ).with(
      :ensure  => 'directory',
      :source  => 'puppet:///path/to/my_scripts',
      :recurse => 'remote'
    ) }
  end

  describe 'removing scripts' do
    let(:params) do {
      :ensure => 'absent',
      :source => 'puppet:///path/to/foo.groovy'
    } end

    it { should contain_elasticsearch__script('foo') }
    it { should contain_file('/usr/share/elasticsearch/scripts/foo.groovy')
      .with(:source => 'puppet:///path/to/foo.groovy', :ensure => 'absent') }
  end
end
