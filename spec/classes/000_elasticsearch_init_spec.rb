# frozen_string_literal: true

require 'spec_helper'

describe 'elasticsearch', type: 'class' do
  default_params = {
    config: { 'node.name' => 'foo' }
  }

  # rubocop:disable RSpec/MultipleMemoizedHelpers
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      case facts[:os]['family']
      when 'Debian'
        let(:defaults_path) { '/etc/default' }
        let(:system_service_folder) { '/lib/systemd/system' }
        let(:pkg_ext) { 'deb' }
        let(:pkg_prov) { 'dpkg' }
        let(:version_add) { '' }

        if (facts[:os]['name'] == 'Debian' && \
           facts[:os]['release']['major'].to_i >= 8) || \
           (facts[:os]['name'] == 'Ubuntu' && \
           facts[:os]['release']['major'].to_i >= 15)
          let(:systemd_service_path) { '/lib/systemd/system' }

          test_pid = true
        else
          test_pid = false
        end
      when 'RedHat'
        let(:defaults_path) { '/etc/sysconfig' }
        let(:system_service_folder) { '/lib/systemd/system' }
        let(:pkg_ext) { 'rpm' }
        let(:pkg_prov) { 'rpm' }
        let(:version_add) { '-1' }

        if facts[:os]['release']['major'].to_i >= 7
          let(:systemd_service_path) { '/lib/systemd/system' }

          test_pid = true
        else
          test_pid = false
        end
      when 'Suse'
        let(:defaults_path) { '/etc/sysconfig' }
        let(:pkg_ext) { 'rpm' }
        let(:pkg_prov) { 'rpm' }
        let(:version_add) { '-1' }

        if facts[:os]['name'] == 'OpenSuSE' &&
           facts[:os]['release']['major'].to_i <= 12
          let(:systemd_service_path) { '/lib/systemd/system' }
        else
          let(:systemd_service_path) { '/usr/lib/systemd/system' }
        end
      end

      let(:facts) do
        facts.merge('scenario' => '', 'common' => '', 'elasticsearch' => {})
      end

      let(:params) do
        default_params.merge({})
      end

      it { is_expected.to compile.with_all_deps }

      # Varies depending on distro
      it { is_expected.to contain_augeas("#{defaults_path}/elasticsearch") }

      # Systemd-specific files
      if test_pid == true
        it {
          expect(subject).to contain_service('elasticsearch').with(
            ensure: 'running',
            enable: true
          )
        }
      end

      context 'java installation' do
        let(:pre_condition) do
          <<-MANIFEST
            include ::java
          MANIFEST
        end

        it {
          expect(subject).to contain_class('elasticsearch::config').
            that_requires('Class[java]')
        }
      end

      context 'package installation' do
        context 'via repository' do
          context 'with specified version' do
            let(:params) do
              default_params.merge(
                version: '1.0'
              )
            end

            it {
              expect(subject).to contain_package('elasticsearch').
                with(ensure: "1.0#{version_add}")
            }
          end

          if facts[:os]['family'] == 'RedHat'
            context 'Handle special CentOS/RHEL package versioning' do
              let(:params) do
                default_params.merge(
                  version: '1.1-2'
                )
              end

              it {
                expect(subject).to contain_package('elasticsearch').
                  with(ensure: '1.1-2')
              }
            end
          end
        end

        context 'when setting package version and package_url' do
          let(:params) do
            default_params.merge(
              version: '0.90.10',
              package_url: "puppet:///path/to/some/es-0.90.10.#{pkg_ext}"
            )
          end

          it { is_expected.to raise_error(Puppet::Error) }
        end

        context 'via package_url setting' do
          ['file:/', 'ftp://', 'http://', 'https://', 'puppet:///'].each do |schema|
            context "using #{schema} schema" do
              let(:params) do
                default_params.merge(
                  package_url: "#{schema}domain-or-path/pkg.#{pkg_ext}"
                )
              end

              unless schema.start_with? 'puppet'
                it {
                  expect(subject).to contain_exec('create_package_dir_elasticsearch').
                    with(command: 'mkdir -p /opt/elasticsearch/swdl')
                }

                it {
                  expect(subject).to contain_file('/opt/elasticsearch/swdl').
                    with(
                      purge: false,
                      force: false,
                      require: 'Exec[create_package_dir_elasticsearch]'
                    )
                }
              end

              case schema
              when 'file:/'
                it {
                  expect(subject).to contain_file(
                    "/opt/elasticsearch/swdl/pkg.#{pkg_ext}"
                  ).with(
                    source: "/domain-or-path/pkg.#{pkg_ext}",
                    backup: false
                  )
                }
              when 'puppet:///'
                it {
                  expect(subject).to contain_file(
                    "/opt/elasticsearch/swdl/pkg.#{pkg_ext}"
                  ).with(
                    source: "#{schema}domain-or-path/pkg.#{pkg_ext}",
                    backup: false
                  )
                }
              else
                [true, false].each do |verify_certificates|
                  context "with download_tool_verify_certificates '#{verify_certificates}'" do
                    let(:params) do
                      default_params.merge(
                        package_url: "#{schema}domain-or-path/pkg.#{pkg_ext}",
                        download_tool_verify_certificates: verify_certificates
                      )
                    end

                    flag = verify_certificates ? '' : ' --no-check-certificate'

                    it {
                      expect(subject).to contain_exec('download_package_elasticsearch').
                        with(
                          command: "wget#{flag} -O /opt/elasticsearch/swdl/pkg.#{pkg_ext} #{schema}domain-or-path/pkg.#{pkg_ext} 2> /dev/null",
                          require: 'File[/opt/elasticsearch/swdl]'
                        )
                    }
                  end
                end
              end

              it {
                expect(subject).to contain_package('elasticsearch').
                  with(
                    ensure: 'present',
                    source: "/opt/elasticsearch/swdl/pkg.#{pkg_ext}",
                    provider: pkg_prov
                  )
              }
            end
          end

          context 'using http:// schema with proxy_url' do
            let(:params) do
              default_params.merge(
                package_url: "http://www.domain.com/package.#{pkg_ext}",
                proxy_url: 'http://proxy.example.com:12345/'
              )
            end

            it {
              expect(subject).to contain_exec('download_package_elasticsearch').
                with(
                  environment: [
                    'use_proxy=yes',
                    'http_proxy=http://proxy.example.com:12345/',
                    'https_proxy=http://proxy.example.com:12345/'
                  ]
                )
            }
          end
        end
      end

      context 'when setting the module to absent' do
        let(:params) do
          default_params.merge(
            ensure: 'absent'
          )
        end

        case facts[:os]['family']
        when 'Suse'
          it {
            expect(subject).to contain_package('elasticsearch').
              with(ensure: 'absent')
          }
        else
          it {
            expect(subject).to contain_package('elasticsearch').
              with(ensure: 'purged')
          }
        end

        it {
          expect(subject).to contain_service('elasticsearch').
            with(
              ensure: 'stopped',
              enable: 'false'
            )
        }

        it {
          expect(subject).to contain_file('/usr/share/elasticsearch/plugins').
            with(ensure: 'absent')
        }

        it {
          expect(subject).to contain_file("#{defaults_path}/elasticsearch").
            with(ensure: 'absent')
        }
      end

      context 'When managing the repository' do
        let(:params) do
          default_params.merge(
            manage_repo: true
          )
        end

        it { is_expected.to contain_class('elastic_stack::repo') }
      end

      context 'When not managing the repository' do
        let(:params) do
          default_params.merge(
            manage_repo: false
          )
        end

        it { is_expected.to compile.with_all_deps }
      end
    end
  end
  # rubocop:enable RSpec/MultipleMemoizedHelpers

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
      let(:facts) do
        facts.merge(
          scenario: '',
          common: ''
        )
      end

      describe 'main class tests' do
        # init.pp
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('elasticsearch') }
        it { is_expected.to contain_class('elasticsearch::package') }

        it {
          expect(subject).to contain_class('elasticsearch::config').
            that_requires('Class[elasticsearch::package]')
        }

        it {
          expect(subject).to contain_class('elasticsearch::service').
            that_requires('Class[elasticsearch::config]')
        }

        # Base directories
        it { is_expected.to contain_file('/etc/elasticsearch') }
        it { is_expected.to contain_file('/usr/share/elasticsearch') }
        it { is_expected.to contain_file('/usr/share/elasticsearch/lib') }
        it { is_expected.to contain_file('/var/lib/elasticsearch') }

        it { is_expected.to contain_exec('remove_plugin_dir') }
      end

      context 'package installation' do
        describe 'with default package' do
          it {
            expect(subject).to contain_package('elasticsearch').
              with(ensure: 'present')
          }

          it {
            expect(subject).not_to contain_package('my-elasticsearch').
              with(ensure: 'present')
          }
        end

        describe 'with specified package name' do
          let(:params) do
            default_params.merge(
              package_name: 'my-elasticsearch'
            )
          end

          it {
            expect(subject).to contain_package('elasticsearch').
              with(ensure: 'present', name: 'my-elasticsearch')
          }

          it {
            expect(subject).not_to contain_package('elasticsearch').
              with(ensure: 'present', name: 'elasticsearch')
          }
        end

        describe 'with auto upgrade enabled' do
          let(:params) do
            default_params.merge(
              autoupgrade: true
            )
          end

          it {
            expect(subject).to contain_package('elasticsearch').
              with(ensure: 'latest')
          }
        end
      end

      describe 'running a a different user' do
        let(:params) do
          default_params.merge(
            elasticsearch_user: 'myesuser',
            elasticsearch_group: 'myesgroup'
          )
        end

        it {
          expect(subject).to contain_file('/etc/elasticsearch').
            with(owner: 'myesuser', group: 'myesgroup')
        }

        it {
          expect(subject).to contain_file('/var/log/elasticsearch').
            with(owner: 'myesuser')
        }

        it {
          expect(subject).to contain_file('/usr/share/elasticsearch').
            with(owner: 'myesuser', group: 'myesgroup')
        }

        it {
          expect(subject).to contain_file('/var/lib/elasticsearch').
            with(owner: 'myesuser', group: 'myesgroup')
        }
      end

      describe 'setting jvm_options' do
        jvm_options = [
          '-Xms16g',
          '-Xmx16g'
        ]

        let(:params) do
          default_params.merge(
            jvm_options: jvm_options
          )
        end

        jvm_options.each do |jvm_option|
          it {
            expect(subject).to contain_file_line("jvm_option_#{jvm_option}").
              with(
                ensure: 'present',
                path: '/etc/elasticsearch/jvm.options',
                line: jvm_option
              )
          }
        end
      end

      context 'with restart_on_change => true' do
        let(:params) do
          default_params.merge(
            restart_on_change: true
          )
        end

        describe 'should restart elasticsearch' do
          it {
            expect(subject).to contain_file('/etc/elasticsearch/elasticsearch.yml').
              that_notifies('Service[elasticsearch]')
          }
        end

        describe 'setting jvm_options triggers restart' do
          let(:params) do
            super().merge(
              jvm_options: ['-Xmx16g']
            )
          end

          it {
            expect(subject).to contain_file_line('jvm_option_-Xmx16g').
              that_notifies('Service[elasticsearch]')
          }
        end
      end

      # This check helps catch dependency cycles.
      context 'create_resource' do
        # Helper for these tests
        def singular(string)
          case string
          when 'indices'
            'index'
          when 'snapshot_repositories'
            'snapshot_repository'
          else
            string[0..-2]
          end
        end

        {
          'indices' => { 'test-index' => {} },
          # 'instances' => { 'es-instance' => {} },
          'pipelines' => { 'testpipeline' => { 'content' => {} } },
          'plugins' => { 'head' => {} },
          'roles' => { 'elastic_role' => {} },
          'scripts' => {
            'foo' => { 'source' => 'puppet:///path/to/foo.groovy' }
          },
          'snapshot_repositories' => { 'backup' => { 'location' => '/backups' } },
          'templates' => { 'foo' => { 'content' => {} } },
          'users' => { 'elastic' => { 'password' => 'foobar' } }
        }.each_pair do |deftype, params|
          describe deftype do
            let(:params) do
              default_params.merge(
                deftype => params
              )
            end

            it { is_expected.to compile }

            it {
              expect(subject).to send(
                "contain_elasticsearch__#{singular(deftype)}", params.keys.first
              )
            }
          end
        end
      end

      describe 'oss' do
        let(:params) do
          default_params.merge(oss: true)
        end

        it do
          expect(subject).to contain_package('elasticsearch').with(
            name: 'elasticsearch-oss'
          )
        end
      end
    end
  end
end
