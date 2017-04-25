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
    describe 'indices' do
      context 'single indices' do
        let(:facts) { facts.merge(:scenario => 'singleindex') }

        it { should contain_elasticsearch__index('baz')
          .with(
            :ensure => 'present',
            :settings => {
              'index' => {
                'number_of_shards' => 1
              }
            }
          ) }
        it { should contain_elasticsearch_index('baz') }
      end

      context 'no indices' do
        let(:facts) { facts.merge(:scenario => '') }

        it { should_not contain_elasticsearch__index('baz') }
      end
    end

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

    describe 'pipelines' do
      context 'single pipeline' do
        let(:facts) { facts.merge(:scenario => 'singlepipeline') }

        it { should contain_elasticsearch__pipeline('testpipeline')
          .with(
            :ensure => 'present',
            :content => {
              'description' => 'Add the foo field',
              'processors' => [
                {
                  'set' => {
                    'field' => 'foo',
                    'value' => 'bar'
                  }
                }
              ]
            }
          ) }
        it { should contain_elasticsearch_pipeline('testpipeline') }
      end

      context 'no pipelines' do
        let(:facts) { facts.merge(:scenario => '') }

        it { should_not contain_elasticsearch__pipeline('testpipeline') }
      end
    end

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

    describe 'roles' do
      context 'single roles' do
        let(:facts) { facts.merge(:scenario => 'singlerole') }
        let(:params) do
          default_params.merge(:security_plugin => 'x-pack')
        end

        it { should contain_elasticsearch__role('admin')
          .with(
            :ensure => 'present',
            :privileges => {
              'cluster' => 'monitor',
              'indices' => {
                '*' => 'all'
              }
            },
            :mappings => [
              'cn=users,dc=example,dc=com'
            ]
          ) }
        it { should contain_elasticsearch_role('admin') }
      end

      context 'no roles' do
        let(:facts) { facts.merge(:scenario => '') }

        it { should_not contain_elasticsearch__role('admin') }
      end
    end

    describe 'scripts' do
      context 'single scripts' do
        let(:facts) { facts.merge(:scenario => 'singlescript') }

        it { should contain_elasticsearch__script('myscript')
          .with(
            :ensure => 'present',
            :source => 'puppet:///file/here'
          ) }
      end

      context 'no roles' do
        let(:facts) { facts.merge(:scenario => '') }

        it { should_not contain_elasticsearch__script('myscript') }
      end
    end

    describe 'templates' do
      context 'single template' do
        let(:facts) { facts.merge(:scenario => 'singletemplate') }

        it { should contain_elasticsearch__template('foo')
          .with(
            :ensure => 'present',
            :content => {
              'template' => 'foo-*',
              'settings' => {
                'index' => {
                  'number_of_replicas' => 0
                }
              }
            }
          ) }
        it { should contain_elasticsearch_template('foo') }
      end

      context 'no templates' do
        let(:facts) { facts.merge(:scenario => '') }

        it { should_not contain_elasticsearch__template('foo') }
      end
    end

    describe 'users' do
      context 'single users' do
        let(:facts) { facts.merge(:scenario => 'singleuser') }
        let(:params) do
          default_params.merge(:security_plugin => 'x-pack')
        end

        it { should contain_elasticsearch__user('elastic')
          .with(
            :ensure => 'present',
            :roles => ['admin'],
            :password => 'password'
          ) }
        it { should contain_elasticsearch_user('elastic') }
      end

      context 'no users' do
        let(:facts) { facts.merge(:scenario => '') }

        it { should_not contain_elasticsearch__user('elastic') }
      end
    end
  end
end
