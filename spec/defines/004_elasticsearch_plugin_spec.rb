# frozen_string_literal: true

require 'spec_helper'
require 'helpers/class_shared_examples'

describe 'elasticsearch::plugin', type: 'define' do
  let(:title) { 'mobz/elasticsearch-head/1.0.0' }

  on_supported_os(
    hardwaremodels: ['x86_64'],
    supported_os: [
      {
        'operatingsystem' => 'CentOS',
        'operatingsystemrelease' => ['6']
      }
    ]
  ).each do |_os, facts|
    let(:facts) do
      facts.merge('scenario' => '', 'common' => '')
    end

    let(:pre_condition) do
      <<-EOS
        class { "elasticsearch":
          config => {
            "node" => {
              "name" => "test"
            }
          }
        }
      EOS
    end

    context 'default values' do
      context 'present' do
        let(:params) do
          {
            ensure: 'present',
            configdir: '/etc/elasticsearch'
          }
        end

        it { is_expected.to compile }
      end

      context 'absent' do
        let(:params) do
          {
            ensure: 'absent'
          }
        end

        it { is_expected.to compile }
      end

      context 'configdir' do
        it {
          expect(subject).to contain_elasticsearch__plugin(
            'mobz/elasticsearch-head/1.0.0'
          ).with_configdir('/etc/elasticsearch')
        }

        it {
          expect(subject).to contain_elasticsearch_plugin(
            'mobz/elasticsearch-head/1.0.0'
          ).with_configdir('/etc/elasticsearch')
        }
      end
    end

    context 'with module_dir' do
      context 'add a plugin' do
        let(:params) do
          {
            ensure: 'present',
            module_dir: 'head'
          }
        end

        it {
          expect(subject).to contain_elasticsearch__plugin(
            'mobz/elasticsearch-head/1.0.0'
          )
        }

        it {
          expect(subject).to contain_elasticsearch_plugin(
            'mobz/elasticsearch-head/1.0.0'
          )
        }

        it {
          expect(subject).to contain_file(
            '/usr/share/elasticsearch/plugins/head'
          ).that_requires(
            'Elasticsearch_plugin[mobz/elasticsearch-head/1.0.0]'
          )
        }
      end

      context 'remove a plugin' do
        let(:params) do
          {
            ensure: 'absent',
            module_dir: 'head'
          }
        end

        it {
          expect(subject).to contain_elasticsearch__plugin(
            'mobz/elasticsearch-head/1.0.0'
          )
        }

        it {
          expect(subject).to contain_elasticsearch_plugin(
            'mobz/elasticsearch-head/1.0.0'
          ).with(
            ensure: 'absent'
          )
        }

        it {
          expect(subject).to contain_file(
            '/usr/share/elasticsearch/plugins/head'
          ).that_requires(
            'Elasticsearch_plugin[mobz/elasticsearch-head/1.0.0]'
          )
        }
      end
    end

    context 'with url' do
      context 'add a plugin with full name' do
        let(:params) do
          {
            ensure: 'present',
            url: 'https://github.com/mobz/elasticsearch-head/archive/master.zip'
          }
        end

        it { is_expected.to contain_elasticsearch__plugin('mobz/elasticsearch-head/1.0.0') }
        it { is_expected.to contain_elasticsearch_plugin('mobz/elasticsearch-head/1.0.0').with(ensure: 'present', url: 'https://github.com/mobz/elasticsearch-head/archive/master.zip') }
      end
    end

    context 'offline plugin install' do
      let(:title) { 'head' }
      let(:params) do
        {
          ensure: 'present',
          source: 'puppet:///path/to/my/plugin.zip'
        }
      end

      it { is_expected.to contain_elasticsearch__plugin('head') }
      it { is_expected.to contain_file('/opt/elasticsearch/swdl/plugin.zip').with(source: 'puppet:///path/to/my/plugin.zip', before: 'Elasticsearch_plugin[head]') }
      it { is_expected.to contain_elasticsearch_plugin('head').with(ensure: 'present', source: '/opt/elasticsearch/swdl/plugin.zip') }
    end

    describe 'service restarts' do
      let(:title) { 'head' }
      let(:params) do
        {
          ensure: 'present',
          module_dir: 'head'
        }
      end

      context 'restart_on_change set to false (default)' do
        let(:pre_condition) do
          <<-EOS
            class { "elasticsearch": }
          EOS
        end

        it {
          expect(subject).not_to contain_elasticsearch_plugin(
            'head'
          ).that_notifies(
            'Service[elasticsearch]'
          )
        }

        include_examples 'class', :sysv
      end

      context 'restart_on_change set to true' do
        let(:pre_condition) do
          <<-EOS
            class { "elasticsearch":
              restart_on_change => true,
            }
          EOS
        end

        it {
          expect(subject).to contain_elasticsearch_plugin(
            'head'
          ).that_notifies(
            'Service[elasticsearch]'
          )
        }

        include_examples('class')
      end

      context 'restart_plugin_change set to false (default)' do
        let(:pre_condition) do
          <<-EOS
            class { "elasticsearch":
              restart_plugin_change => false,
            }
          EOS
        end

        it {
          expect(subject).not_to contain_elasticsearch_plugin(
            'head'
          ).that_notifies(
            'Service[elasticsearch]'
          )
        }

        include_examples('class')
      end

      context 'restart_plugin_change set to true' do
        let(:pre_condition) do
          <<-EOS
            class { "elasticsearch":
              restart_plugin_change => true,
            }
          EOS
        end

        it {
          expect(subject).to contain_elasticsearch_plugin(
            'head'
          ).that_notifies(
            'Service[elasticsearch]'
          )
        }

        include_examples('class')
      end
    end

    describe 'proxy arguments' do
      let(:title) { 'head' }

      context 'unauthenticated' do
        context 'on define' do
          let(:params) do
            {
              ensure: 'present',
              proxy_host: 'es.local',
              proxy_port: 8080
            }
          end

          it {
            expect(subject).to contain_elasticsearch_plugin(
              'head'
            ).with_proxy(
              'http://es.local:8080'
            )
          }
        end

        context 'on main class' do
          let(:params) do
            {
              ensure: 'present'
            }
          end

          let(:pre_condition) do
            <<-EOS
              class { 'elasticsearch':
                proxy_url => 'https://es.local:8080',
              }
            EOS
          end

          it {
            expect(subject).to contain_elasticsearch_plugin(
              'head'
            ).with_proxy(
              'https://es.local:8080'
            )
          }
        end
      end

      context 'authenticated' do
        context 'on define' do
          let(:params) do
            {
              ensure: 'present',
              proxy_host: 'es.local',
              proxy_port: 8080,
              proxy_username: 'elastic',
              proxy_password: 'password'
            }
          end

          it {
            expect(subject).to contain_elasticsearch_plugin(
              'head'
            ).with_proxy(
              'http://elastic:password@es.local:8080'
            )
          }
        end

        context 'on main class' do
          let(:params) do
            {
              ensure: 'present'
            }
          end

          let(:pre_condition) do
            <<-EOS
              class { 'elasticsearch':
                proxy_url => 'http://elastic:password@es.local:8080',
              }
            EOS
          end

          it {
            expect(subject).to contain_elasticsearch_plugin(
              'head'
            ).with_proxy(
              'http://elastic:password@es.local:8080'
            )
          }
        end
      end
    end

    describe 'collector ordering' do
      describe 'present' do
        let(:title) { 'head' }
        let(:pre_condition) do
          <<-EOS
            class { 'elasticsearch': }
          EOS
        end

        it {
          expect(subject).to contain_elasticsearch__plugin(
            'head'
          ).that_requires(
            'Class[elasticsearch::config]'
          )
        }

        it {
          expect(subject).to contain_elasticsearch_plugin(
            'head'
          ).that_comes_before(
            'Service[elasticsearch]'
          )
        }

        include_examples 'class'
      end
    end
  end
end
