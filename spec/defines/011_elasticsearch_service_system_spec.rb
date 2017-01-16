require 'spec_helper'

describe 'elasticsearch::service::systemd', :type => 'define' do

  on_supported_os({
    :hardwaremodels => ['x86_64'],
    :supported_os => [
      {
        'operatingsystem' => 'OpenSuSE',
        'operatingsystemrelease' => ['12', '13'],
      },
      {
        'operatingsystem' => 'CentOS',
        'operatingsystemrelease' => ['7'],
      }
    ]
  }).each do |os, facts|

    context "on #{os}" do

      let(:facts) { facts.merge({
          :scenario => '',
          :common => ''
      }) }
      let(:title) { 'es-01' }
      let(:pre_condition) {%q{
        class { "elasticsearch":
          config => { "node" => {"name" => "test" }}
        }
      }}

      if facts[:operatingsystem] == 'OpenSuSE' and
        facts[:operatingsystemrelease].to_i >= 13
        let(:systemd_service_path) { '/usr/lib/systemd/system' }
      else
        let(:systemd_service_path) { '/lib/systemd/system' }
      end

      context 'setup service' do

        let :params do {
          :ensure => 'present',
          :status => 'enabled'
        } end

        it { should contain_elasticsearch__service__systemd('es-01') }
        it { should contain_exec('systemd_reload_es-01')
          .with(:command => '/bin/systemctl daemon-reload') }
        it { should contain_service('elasticsearch-instance-es-01')
          .with(:ensure => 'running', :enable => true, :provider => 'systemd') }
      end

      context 'remove service' do

        let :params do {
          :ensure => 'absent'
        } end

        it { should contain_elasticsearch__service__systemd('es-01') }
        it { should contain_exec('systemd_reload_es-01')
          .with(:command => '/bin/systemctl daemon-reload') }
        it { should contain_service('elasticsearch-instance-es-01')
          .with(:ensure => 'stopped', :enable => false, :provider => 'systemd') }
      end

      context 'unmanaged' do
        let :params do {
          :ensure => 'present',
          :status => 'unmanaged'
        } end


        it { should contain_elasticsearch__service__systemd('es-01') }
        it { should contain_service('elasticsearch-instance-es-01')
          .with(:enable => false) }
        it { should contain_augeas('defaults_es-01') }

      end

      context 'defaults file' do

        context 'set via file' do
          let :params do {
            :ensure => 'present',
            :status => 'enabled',
            :init_defaults_file => 'puppet:///path/to/initdefaultsfile'
          } end

          it { should contain_file('/etc/sysconfig/elasticsearch-es-01')
            .with(
              :source => 'puppet:///path/to/initdefaultsfile',
              :before => 'Service[elasticsearch-instance-es-01]'
          ) }
        end

        context 'set via hash' do
          let :params do {
            :ensure        => 'present',
            :status        => 'enabled',
            :init_defaults => {'ES_HOME' => '/usr/share/elasticsearch' }
          } end

          it { should contain_augeas('defaults_es-01')
            .with(
              :incl => '/etc/sysconfig/elasticsearch-es-01',
              :changes => [
                "set ES_GROUP 'elasticsearch'",
                "set ES_HOME '/usr/share/elasticsearch'",
                "set ES_USER 'elasticsearch'",
                "set MAX_OPEN_FILES '65536'"
              ].join("\n") << "\n",
              :before => 'Service[elasticsearch-instance-es-01]'
          ) }
        end

        context 'restarts when "restart_on_change" is true' do
          let(:pre_condition) {%q{
            class { "elasticsearch":
              config => { "node" => {"name" => "test" }},
              restart_on_change => true
            }
          }}

          context 'set via file' do
            let :params do {
              :ensure             => 'present',
              :status             => 'enabled',
              :init_defaults_file =>
                'puppet:///path/to/initdefaultsfile'
            } end

            it { should contain_file(
              '/etc/sysconfig/elasticsearch-es-01'
            ).with(:source => 'puppet:///path/to/initdefaultsfile') }
            it { should contain_file(
              '/etc/sysconfig/elasticsearch-es-01'
            ).that_notifies([
              'Service[elasticsearch-instance-es-01]',
            ]) }
          end

          context 'set via hash' do
            let :params do {
              :ensure => 'present',
              :status => 'enabled',
              :init_defaults => {
                'ES_HOME' => '/usr/share/elasticsearch'
              }
            } end

            it { should contain_augeas(
              'defaults_es-01'
            ).with(
              :incl => '/etc/sysconfig/elasticsearch-es-01',
              :changes => [
                "set ES_GROUP 'elasticsearch'",
                "set ES_HOME '/usr/share/elasticsearch'",
                "set ES_USER 'elasticsearch'",
                "set MAX_OPEN_FILES '65536'"
              ].join("\n") << "\n"
            )}
            it { should contain_augeas(
              'defaults_es-01'
            ).that_comes_before(
              'Service[elasticsearch-instance-es-01]'
            ) }
            it { should contain_augeas(
              'defaults_es-01'
            ).that_notifies(
              'Exec[systemd_reload_es-01]'
            ) }
          end
        end

        context 'does not restart when "restart_on_change" is false' do
          let(:pre_condition) {%q{
            class { "elasticsearch":
              config => { "node" => {"name" => "test" }},
            }
          }}

          context 'set via file' do
            let :params do {
              :ensure             => 'present',
              :status             => 'enabled',
              :init_defaults_file =>
                'puppet:///path/to/initdefaultsfile'
            } end

            it { should_not contain_file(
              '/etc/sysconfig/elasticsearch-es-01'
            ).that_notifies(
              'Service[elasticsearch-instance-es-01]',
            ) }
          end
        end
      end

      context 'init file' do
        let(:pre_condition) {%q{
          class { "elasticsearch":
            config => { "node" => {"name" => "test" }}
          }
        }}

        context 'via template' do
          let :params do {
            :ensure => 'present',
            :status => 'enabled',
            :init_template =>
              'elasticsearch/etc/init.d/elasticsearch.systemd.erb'
          } end

          it do
            should contain_elasticsearch_service_file(
              "#{systemd_service_path}/elasticsearch-es-01.service"
            ).with(
              :before => "File[#{systemd_service_path}/elasticsearch-es-01.service]"
            )
          end

          it do
            should contain_file(
              "#{systemd_service_path}/elasticsearch-es-01.service"
            ).with(
              :before => 'Service[elasticsearch-instance-es-01]'
            )
          end
        end

        context 'restarts when "restart_on_change" is true' do
          let(:pre_condition) {%q{
            class { "elasticsearch":
              config => { "node" => {"name" => "test" }},
              restart_on_change => true
            }
          }}

          let :params do {
            :ensure => 'present',
            :status => 'enabled',
            :init_template =>
              'elasticsearch/etc/init.d/elasticsearch.systemd.erb'
          } end

          it { should contain_file(
            "#{systemd_service_path}/elasticsearch-es-01.service"
          ).that_notifies([
            'Exec[systemd_reload_es-01]',
            'Service[elasticsearch-instance-es-01]'
          ]) }
          it { should contain_file(
            "#{systemd_service_path}/elasticsearch-es-01.service"
          ).that_comes_before(
            'Service[elasticsearch-instance-es-01]'
          ) }
        end

        context 'does not restart when "restart_on_change" is false' do
          let(:pre_condition) {%q{
            class { "elasticsearch":
              config => { "node" => {"name" => "test" }},
            }
          }}

          let :params do {
            :ensure => 'present',
            :status => 'enabled',
            :init_template =>
              'elasticsearch/etc/init.d/elasticsearch.systemd.erb'
          } end

          it { should_not contain_file(
            "#{systemd_service_path}/elasticsearch-es-01.service"
          ).that_notifies(
            'Service[elasticsearch-instance-es-01]'
          ) }
        end
      end
    end # of context on os
  end # of on_supported_os
end # of describe elasticsearch::service::systemd
