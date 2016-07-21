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
    class { 'elasticsearch': }
  EOS
  }

  describe 'template from file' do

    let :params do {
      :ensure => 'present',
      :source => 'puppet:///path/to/foo.json',
    } end

    it { should contain_elasticsearch_template('foo').with(
      :ensure => 'present',
      :source => 'puppet:///path/to/foo.json',
    ) }
  end

  describe 'template deletion' do

    let :params do {
      :ensure => 'absent',
      :source => 'puppet:///path/to/foo.json',
    } end

    it { should contain_elasticsearch_template('foo').with(
      :ensure => 'absent'
    ) }
  end

end
