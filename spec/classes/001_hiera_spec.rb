require 'spec_helper'

shared_examples 'instance' do |name|
  it { should contain_elasticsearch__instance(name).with(
    :config => {
      'node.name' => name,
      'network.host' => '0.0.0.0'
    }
  )}
  it { should contain_elasticsearch__service(name) }
  it { should contain_elasticsearch__service__init(name) }
  it { should contain_service("elasticsearch-instance-#{name}") }
  it { should contain_augeas("defaults_#{name}") }
  it { should contain_file("/etc/elasticsearch/#{name}")
    .with(:ensure => 'directory') }
  it { should contain_file("/etc/elasticsearch/#{name}/elasticsearch.yml") }
  it { should contain_file("/etc/elasticsearch/#{name}/logging.yml") }
  it { should contain_file("/etc/elasticsearch/#{name}/log4j2.properties") }
  it { should contain_exec("mkdir_logdir_elasticsearch_#{name}")
    .with(:command => "mkdir -p /var/log/elasticsearch/#{name}") }
  it { should contain_exec("mkdir_datadir_elasticsearch_#{name}")
    .with(:command => "mkdir -p /var/lib/elasticsearch/#{name}") }
  it { should contain_exec("mkdir_configdir_elasticsearch_#{name}") }
  it { should contain_file("/var/lib/elasticsearch/#{name}") }
  it { should contain_file("/var/log/elasticsearch/#{name}") }
  it { should contain_elasticsearch_service_file(
    "/etc/init.d/elasticsearch-#{name}"
  ) }
  it { should contain_file("/etc/init.d/elasticsearch-#{name}") }
  it { should contain_file("/etc/elasticsearch/#{name}/scripts")
    .with(:target => '/usr/share/elasticsearch/scripts') }
  it { should contain_datacat_fragment("main_config_#{name}") }
  it { should contain_datacat(
    "/etc/elasticsearch/#{name}/elasticsearch.yml"
  ) }
end

describe 'elasticsearch', :type => 'class' do
  default_params = {
    :config => { 'node.name' => 'foo' }
  }

  facts = {
    :common => '',
    :kernel => 'Linux',
    :operatingsystem => 'CentOS',
    :operatingsystemmajrelease => '6',
    :osfamily => 'RedHat'
  }

  let(:params) do
    default_params.merge({})
  end

  context 'hiera' do
    describe 'instances' do
      context 'single instance' do
        let(:facts) { facts.merge(:scenario => 'singleinstance') }

        include_examples 'instance', 'es-01'
      end

      context 'multiple instances' do
        let(:facts) { facts.merge(:scenario => 'multipleinstances') }

        include_examples 'instance', 'es-01'
        include_examples 'instance', 'es-02'
      end

      context 'no instances' do
        let(:facts) { facts.merge(:scenario => '') }

        it { should_not contain_elasticsearch__instance('es-01') }
        it { should_not contain_elasticsearch__instance('es-02') }
      end

      context 'multiple instances using hiera_merge' do
        let(:params) { default_params.merge(:instances_hiera_merge => true) }

        let(:facts) do
          facts.merge(
            :common => 'defaultinstance',
            :scenario => 'singleinstance'
          )
        end

        include_examples 'instance', 'default'
        include_examples 'instance', 'es-01'
      end
    end # of instances

    describe 'plugins' do
      context 'single plugin' do
        let(:facts) { facts.merge(:scenario => 'singleplugin') }

        it { should contain_elasticsearch__plugin('mobz/elasticsearch-head')
          .with(
            :ensure => 'present',
            :module_dir => 'head',
            :instances => ['es-01']
          ) }
        it { should contain_elasticsearch_plugin('mobz/elasticsearch-head') }
      end

      context 'no plugins' do
        let(:facts) { facts.merge(:scenario => '') }

        it { should_not contain_elasticsearch__plugin(
          'mobz/elasticsearch-head/1.0.0'
        ) }
      end
    end
  end
end
