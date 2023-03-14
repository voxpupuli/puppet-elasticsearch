# frozen_string_literal: true

require 'spec_helper'

describe 'elasticsearch', type: 'class' do
  default_params = {
    config: { 'node.name' => 'foo' }
  }

  let(:params) do
    default_params.merge({})
  end

  on_supported_os(
    hardwaremodels: ['x86_64'],
    supported_os: [
      {
        'operatingsystem' => 'CentOS',
        'operatingsystemrelease' => ['7']
      }
    ]
  ).each do |os, facts|
    context "on #{os}" do
      context 'hiera' do
        describe 'indices' do
          context 'single indices' do
            let(:facts) { facts.merge(scenario: 'singleindex') }

            it {
              expect(subject).to contain_elasticsearch__index('baz').
                with(
                  ensure: 'present',
                  settings: {
                    'index' => {
                      'number_of_shards' => 1
                    }
                  }
                )
            }

            it { is_expected.to contain_elasticsearch_index('baz') }

            it {
              expect(subject).to contain_es_instance_conn_validator(
                'baz-index-conn-validator'
              )
            }
          end

          context 'no indices' do
            let(:facts) { facts.merge(scenario: '') }

            it { is_expected.not_to contain_elasticsearch__index('baz') }
          end
        end

        context 'config' do
          let(:facts) { facts.merge(scenario: 'singleinstance') }

          it { is_expected.to contain_augeas('/etc/sysconfig/elasticsearch') }
          it { is_expected.to contain_file('/etc/elasticsearch/elasticsearch.yml') }

          it {
            expect(subject).to contain_service('elasticsearch').with(
              ensure: 'running',
              enable: true
            )
          }
        end

        describe 'pipelines' do
          context 'single pipeline' do
            let(:facts) { facts.merge(scenario: 'singlepipeline') }

            it {
              expect(subject).to contain_elasticsearch__pipeline('testpipeline').
                with(
                  ensure: 'present',
                  content: {
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
                )
            }

            it { is_expected.to contain_elasticsearch_pipeline('testpipeline') }
          end

          context 'no pipelines' do
            let(:facts) { facts.merge(scenario: '') }

            it { is_expected.not_to contain_elasticsearch__pipeline('testpipeline') }
          end
        end

        describe 'plugins' do
          context 'single plugin' do
            let(:facts) { facts.merge(scenario: 'singleplugin') }

            it {
              expect(subject).to contain_elasticsearch__plugin('mobz/elasticsearch-head').
                with(
                  ensure: 'present',
                  module_dir: 'head'
                )
            }

            it { is_expected.to contain_elasticsearch_plugin('mobz/elasticsearch-head') }
          end

          context 'no plugins' do
            let(:facts) { facts.merge(scenario: '') }

            it {
              expect(subject).not_to contain_elasticsearch__plugin(
                'mobz/elasticsearch-head/1.0.0'
              )
            }
          end
        end

        describe 'roles' do
          context 'single roles' do
            let(:facts) { facts.merge(scenario: 'singlerole') }
            let(:params) do
              default_params
            end

            it {
              expect(subject).to contain_elasticsearch__role('admin').
                with(
                  ensure: 'present',
                  privileges: {
                    'cluster' => 'monitor',
                    'indices' => {
                      '*' => 'all'
                    }
                  },
                  mappings: [
                    'cn=users,dc=example,dc=com'
                  ]
                )
            }

            it { is_expected.to contain_elasticsearch_role('admin') }
            it { is_expected.to contain_elasticsearch_role_mapping('admin') }
          end

          context 'no roles' do
            let(:facts) { facts.merge(scenario: '') }

            it { is_expected.not_to contain_elasticsearch__role('admin') }
          end
        end

        describe 'scripts' do
          context 'single scripts' do
            let(:facts) { facts.merge(scenario: 'singlescript') }

            it {
              expect(subject).to contain_elasticsearch__script('myscript').
                with(
                  ensure: 'present',
                  source: 'puppet:///file/here'
                )
            }

            it { is_expected.to contain_file('/usr/share/elasticsearch/scripts/here') }
          end

          context 'no roles' do
            let(:facts) { facts.merge(scenario: '') }

            it { is_expected.not_to contain_elasticsearch__script('myscript') }
          end
        end

        describe 'templates' do
          context 'single template' do
            let(:facts) { facts.merge(scenario: 'singletemplate') }

            it {
              expect(subject).to contain_elasticsearch__template('foo').
                with(
                  ensure: 'present',
                  content: {
                    'template' => 'foo-*',
                    'settings' => {
                      'index' => {
                        'number_of_replicas' => 0
                      }
                    }
                  }
                )
            }

            it { is_expected.to contain_elasticsearch_template('foo') }
          end

          context 'composable template' do
            let(:facts) { facts.merge(scenario: 'composabletemplate') }

            it {
              expect(subject).to contain_elasticsearch__component_template('b1').
                with(
                  ensure: 'present',
                  content: {
                    'template' => {
                      'mappings' => {
                        'properties' => {
                          'baz1' => {
                            'type' => 'keyword'
                          }
                        }
                      }
                    }
                  }
                )
            }

            it { is_expected.to contain_elasticsearch_component_template('b1') }

            it {
              expect(subject).to contain_es_instance_conn_validator(
                'b1-component_template-conn-validator'
              )
            }

            it {
              expect(subject).to contain_elasticsearch__index_template('foo').
                with(
                  ensure: 'present',
                  content: {
                    'index_patterns' => ['foo-*']
                  }
                )
            }

            it {
              expect(subject).to contain_es_instance_conn_validator(
                'foo-index_template-conn-validator'
              )
            }

            it { is_expected.to contain_elasticsearch_index_template('foo') }

            it {
              expect(subject).to contain_elasticsearch__index_template('baz').
                with(
                  ensure: 'present',
                  content: {
                    'index_patterns' => ['baz-*'],
                    'template' => {
                      'settings' => {
                        'index' => {
                          'number_of_replicas' => 1
                        }
                      },
                      'mappings' => {
                        '_source' => {
                          'enabled' => true
                        },
                        'properties' => {
                          'host_name' => {
                            'type' => 'keyword'
                          },
                          'created_at' => {
                            'type' => 'date',
                            'format' => 'EEE MMM dd HH:mm:ss Z yyyy'
                          }
                        }
                      }
                    },
                    'composed_of' => ['b1'],
                    'priority' => 10,
                    'version' => 3,
                    '_meta' => {
                      'description' => 'my custom'
                    }
                  }
                )
            }

            it {
              expect(subject).to contain_es_instance_conn_validator(
                'baz-index_template-conn-validator'
              )
            }

            it { is_expected.to contain_elasticsearch_index_template('baz') }
          end

          context 'no templates' do
            let(:facts) { facts.merge(scenario: '') }

            it { is_expected.not_to contain_elasticsearch__template('foo') }
          end
        end

        describe 'ilm policies' do
          context 'single ilm policy' do
            let(:facts) { facts.merge(scenario: 'singleilmpolicy') }

            it {
              expect(subject).to contain_elasticsearch__ilm_policy('mypolicy').
                with(
                  ensure: 'present',
                  content: {
                    'policy' => {
                      'phases' => {
                        'warm' => {
                          'min_age' => '2d',
                          'actions' => {
                            'shrink' => {
                              'number_of_shards' => 1
                            },
                            'forcemerge' => {
                              'max_num_segments' => 1
                            }
                          }
                        },
                        'cold' => {
                          'min_age' => '30d'
                        }
                      }
                    }
                  }
                )
            }

            it {
              expect(subject).to contain_es_instance_conn_validator(
                'mypolicy-ilm_policy-conn-validator'
              )
            }

            it { is_expected.to contain_elasticsearch_ilm_policy('mypolicy') }
          end

          context 'no ilm policy' do
            let(:facts) { facts.merge(scenario: '') }

            it { is_expected.not_to contain_elasticsearch__ilm_policy('mypolicy') }
          end
        end

        describe 'slm policies' do
          context 'single slm policy' do
            let(:facts) { facts.merge(scenario: 'singleslmpolicy') }

            it {
              expect(subject).to contain_elasticsearch__slm_policy('mypolicy').
                with(
                  ensure: 'present',
                  content: {
                    'name' => '<backup-{now/d}>',
                    'schedule' => '0 30 1 * * ?',
                    'repository' => 'backup',
                    'config' => {},
                    'retention' => {
                      'expire_after' => '60d',
                      'min_count' => 2,
                      'max_count' => 10
                    }
                  }
                )
            }

            it {
              expect(subject).to contain_es_instance_conn_validator(
                'mypolicy-slm_policy-conn-validator'
              )
            }

            it { is_expected.to contain_elasticsearch_slm_policy('mypolicy') }
          end

          context 'no slm policy' do
            let(:facts) { facts.merge(scenario: '') }

            it { is_expected.not_to contain_elasticsearch__slm_policy('mypolicy') }
          end
        end

        describe 'users' do
          context 'single users' do
            let(:facts) { facts.merge(scenario: 'singleuser') }
            let(:params) do
              default_params
            end

            it {
              expect(subject).to contain_elasticsearch__user('elastic').
                with(
                  ensure: 'present',
                  roles: ['admin'],
                  password: 'password'
                )
            }

            it { is_expected.to contain_elasticsearch_user('elastic') }
          end

          context 'no users' do
            let(:facts) { facts.merge(scenario: '') }

            it { is_expected.not_to contain_elasticsearch__user('elastic') }
          end
        end
      end
    end
  end
end
