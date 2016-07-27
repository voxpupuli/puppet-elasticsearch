require 'spec_helper'

describe 'elasticsearch::plugin', :type => 'define' do

  let(:title) { 'mobz/elasticsearch-head/1.0.0' }
  let :facts do {
    :operatingsystem => 'CentOS',
    :kernel => 'Linux',
    :osfamily => 'RedHat',
    :operatingsystemmajrelease => '6',
    :scenario => '',
    :common => ''
  } end

  let(:pre_condition) {%q{
    class { "elasticsearch":
      config => {
        "node" => {
          "name" => "test"
        }
      }
    }
  }}

  context 'with module_dir' do

    context "Add a plugin" do

      let :params do {
        :ensure     => 'present',
        :module_dir => 'head',
        :instances  => 'es-01'
      } end

      it { should contain_elasticsearch__plugin('mobz/elasticsearch-head/1.0.0') }
      it { should contain_elasticsearch_plugin('mobz/elasticsearch-head/1.0.0') }
    end

    context "Remove a plugin" do

      let :params do {
        :ensure     => 'absent',
        :module_dir => 'head',
        :instances  => 'es-01'
      } end

      it { should contain_elasticsearch__plugin('mobz/elasticsearch-head/1.0.0') }
      it { should contain_elasticsearch_plugin('mobz/elasticsearch-head/1.0.0').with(:ensure => 'absent') }
    end

  end

  context 'with url' do

    context "Add a plugin with full name" do

      let :params do {
        :ensure     => 'present',
        :instances  => 'es-01',
        :url        => 'https://github.com/mobz/elasticsearch-head/archive/master.zip',
      } end

      it { should contain_elasticsearch__plugin('mobz/elasticsearch-head/1.0.0') }
      it { should contain_elasticsearch_plugin('mobz/elasticsearch-head/1.0.0').with(:ensure => 'present', :url => 'https://github.com/mobz/elasticsearch-head/archive/master.zip') }
    end

  end

  context "offline plugin install" do

      let(:title) { 'head' }
      let :params do {
        :ensure     => 'present',
        :instances  => 'es-01',
        :source     => 'puppet:///path/to/my/plugin.zip',
      } end

      it { should contain_elasticsearch__plugin('head') }
      it { should contain_file('/opt/elasticsearch/swdl/plugin.zip').with(:source => 'puppet:///path/to/my/plugin.zip', :before => 'Elasticsearch_plugin[head]') }
      it { should contain_elasticsearch_plugin('head').with(:ensure => 'present', :source => '/opt/elasticsearch/swdl/plugin.zip') }

  end

  describe 'service restarts' do

    let(:title) { 'head' }
    let :params do {
      :ensure     => 'present',
      :instances  => 'es-01',
      :module_dir => 'head',
    } end

    context 'restart_on_change set to false (default)' do
      let(:pre_condition) { %q{
        class { "elasticsearch": }

        elasticsearch::instance { 'es-01': }
      }}

      it { should_not contain_elasticsearch_plugin(
        'head'
      ).that_notifies(
        'Elasticsearch::Service[es-01]'
      )}
    end

    context 'restart_on_change set to true' do
      let(:pre_condition) { %q{
        class { "elasticsearch":
          restart_on_change => true,
        }

        elasticsearch::instance { 'es-01': }
      }}

      it { should contain_elasticsearch_plugin(
        'head'
      ).that_notifies(
        'Elasticsearch::Service[es-01]'
      )}
    end

    context 'restart_plugin_change set to false (default)' do
      let(:pre_condition) { %q{
        class { "elasticsearch":
          restart_plugin_change => false,
        }

        elasticsearch::instance { 'es-01': }
      }}

      it { should_not contain_elasticsearch_plugin(
        'head'
      ).that_notifies(
        'Elasticsearch::Service[es-01]'
      )}
    end

    context 'restart_plugin_change set to true' do
      let(:pre_condition) { %q{
        class { "elasticsearch":
          restart_plugin_change => true,
        }

        elasticsearch::instance { 'es-01': }
      }}

      it { should contain_elasticsearch_plugin(
        'head'
      ).that_notifies(
        'Elasticsearch::Service[es-01]'
      )}
    end

  end

  describe 'proxy arguments' do

    let(:title) { 'head' }

    context 'on define' do
      let :params do {
        :ensure     => 'present',
        :instances  => 'es-01',
        :proxy_host => 'es.local',
        :proxy_port => '8080'
      } end

      it { should contain_elasticsearch_plugin(
        'head'
      ).with_proxy_args(
        ['http', 'https'].map do |proto|
          "-D#{proto}.proxyPort=8080 -D#{proto}.proxyHost=es.local"
        end.join(' ')
      )}
    end

    context 'on main class' do
      let :params do {
        :ensure    => 'present',
        :instances => 'es-01'
      } end

      let(:pre_condition) { %q{
        class { 'elasticsearch':
          proxy_url => 'http://es.local:8080',
        }
      }}

      it { should contain_elasticsearch_plugin(
        'head'
      ).with_proxy_args(
        ['http', 'https'].map do |proto|
          "-D#{proto}.proxyPort=8080 -D#{proto}.proxyHost=es.local"
        end.join(' ')
      )}
    end

  end

end
