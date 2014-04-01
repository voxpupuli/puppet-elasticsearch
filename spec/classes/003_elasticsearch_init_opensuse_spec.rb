require 'spec_helper'

describe 'elasticsearch', :type => 'class' do

  default_params = {
    :config  => { 'node.name' => 'foo' }
  }

  [ 'OpenSuSE' ].each do |distro|

    context "on #{distro} OS" do

      let :facts do {
        :operatingsystem => distro,
        :kernel => 'Linux',
        :osfamily => 'Suse'
      } end

      let (:params) {
        default_params
      }

      context 'Main class' do

				it { should compile.with_all_deps }
        # init.pp
        it { should contain_anchor('elasticsearch::begin') }
        it { should contain_anchor('elasticsearch::end').that_requires('Class[elasticsearch::service]') }
        it { should contain_class('elasticsearch::params') }
        it { should contain_class('elasticsearch::package').that_requires('Anchor[elasticsearch::begin]') }
        it { should contain_class('elasticsearch::config').that_requires('Class[elasticsearch::package]') }
        it { should contain_class('elasticsearch::service').that_requires('Class[elasticsearch::package]').that_requires('Class[elasticsearch::config]') }

        # Base directories
        it { should contain_file('/etc/elasticsearch') }
        it { should contain_file('/etc/elasticsearch/elasticsearch.yml') }
        it { should contain_exec('mkdir_templates_elasticsearch').with(:command => 'mkdir -p /etc/elasticsearch/templates_import', :creates => '/etc/elasticsearch/templates_import') }
        it { should contain_file('/etc/elasticsearch/templates_import').with(:require => 'Exec[mkdir_templates_elasticsearch]') }
				it { should contain_file('/usr/share/elasticsearch/plugins') }

      end

      context 'package installation' do

        context 'via repository' do

          context 'with default settings' do

           it { should contain_package('elasticsearch').with(:ensure => 'present') }

          end

          context 'with specified version' do

            let (:params) {
              default_params.merge({
                :version => '1.0'
              })
            }

            it { should contain_package('elasticsearch').with(:ensure => '1.0') }
          end

          context 'with auto upgrade enabled' do

            let (:params) {
              default_params.merge({
                :autoupgrade => true
              })
            }

            it { should contain_package('elasticsearch').with(:ensure => 'latest') }
          end

        end

        context 'when setting package version and package_url' do

          let (:params) {
            default_params.merge({
              :version     => '0.90.10',
              :package_url => 'puppet:///path/to/some/elasticsearch-0.90.10.rpm'
            })
          }

          it { expect { should raise_error(Puppet::Error) } }

        end

        context 'via package_url setting' do

          context 'using puppet:/// schema' do

            let (:params) {
              default_params.merge({
                :package_url => 'puppet:///path/to/package.rpm'
              })
            }

            it { should contain_file('/opt/elasticsearch/swdl/package.rpm').with(:source => 'puppet:///path/to/package.rpm', :backup => false) }
            it { should contain_package('elasticsearch').with(:ensure => 'present', :source => '/opt/elasticsearch/swdl/package.rpm', :provider => 'rpm') }
          end

          context 'using http:// schema' do

            let (:params) {
              default_params.merge({
                :package_url => 'http://www.domain.com/path/to/package.rpm'
              })
            }

            it { should contain_exec('create_package_dir_elasticsearch').with(:command => 'mkdir -p /opt/elasticsearch/swdl') }
            it { should contain_file('/opt/elasticsearch/swdl').with(:purge => false, :force => false, :require => "Exec[create_package_dir_elasticsearch]") }
            it { should contain_exec('download_package_elasticsearch').with(:command => 'wget -O /opt/elasticsearch/swdl/package.rpm http://www.domain.com/path/to/package.rpm 2> /dev/null', :require => 'File[/opt/elasticsearch/swdl]') }
            it { should contain_package('elasticsearch').with(:ensure => 'present', :source => '/opt/elasticsearch/swdl/package.rpm', :provider => 'rpm') }
          end

          context 'using https:// schema' do

            let (:params) {
              default_params.merge({
                :package_url => 'https://www.domain.com/path/to/package.rpm'
              })
            }

            it { should contain_exec('create_package_dir_elasticsearch').with(:command => 'mkdir -p /opt/elasticsearch/swdl') }
            it { should contain_file('/opt/elasticsearch/swdl').with(:purge => false, :force => false, :require => 'Exec[create_package_dir_elasticsearch]') }
            it { should contain_exec('download_package_elasticsearch').with(:command => 'wget -O /opt/elasticsearch/swdl/package.rpm https://www.domain.com/path/to/package.rpm 2> /dev/null', :require => 'File[/opt/elasticsearch/swdl]') }
            it { should contain_package('elasticsearch').with(:ensure => 'present', :source => '/opt/elasticsearch/swdl/package.rpm', :provider => 'rpm') }
          end

          context 'using ftp:// schema' do

            let (:params) {
              default_params.merge({
                :package_url => 'ftp://www.domain.com/path/to/package.rpm'
              })
            }

            it { should contain_exec('create_package_dir_elasticsearch').with(:command => 'mkdir -p /opt/elasticsearch/swdl') }
            it { should contain_file('/opt/elasticsearch/swdl').with(:purge => false, :force => false, :require => 'Exec[create_package_dir_elasticsearch]') }
            it { should contain_exec('download_package_elasticsearch').with(:command => 'wget -O /opt/elasticsearch/swdl/package.rpm ftp://www.domain.com/path/to/package.rpm 2> /dev/null', :require => 'File[/opt/elasticsearch/swdl]') }
            it { should contain_package('elasticsearch').with(:ensure => 'present', :source => '/opt/elasticsearch/swdl/package.rpm', :provider => 'rpm') }
          end

          context 'using file:// schema' do

            let (:params) {
              default_params.merge({
                :package_url => 'file:/path/to/package.rpm'
              })
            }

            it { should contain_exec('create_package_dir_elasticsearch').with(:command => 'mkdir -p /opt/elasticsearch/swdl') }
            it { should contain_file('/opt/elasticsearch/swdl').with(:purge => false, :force => false, :require => 'Exec[create_package_dir_elasticsearch]') }
            it { should contain_file('/opt/elasticsearch/swdl/package.rpm').with(:source => '/path/to/package.rpm', :backup => false) }
            it { should contain_package('elasticsearch').with(:ensure => 'present', :source => '/opt/elasticsearch/swdl/package.rpm', :provider => 'rpm') }
          end

        end

      end # package

      context 'service setup' do

        context 'with provider \'systemd\'' do

          it { should contain_elasticsearch__service__systemd('elasticsearch') }

          context 'and default settings' do

            it { should contain_service('elasticsearch').with(:ensure => 'running') }

          end

          context 'and set defaults via hash param' do

            let (:params) {
              default_params.merge({
                :init_defaults => { 'ES_USER' => 'root', 'ES_GROUP' => 'root', 'ES_JAVA_OPTS' => '"-server -XX:+UseTLAB -XX:+CMSClassUnloadingEnabled"' }
              })
            }

            it { should contain_augeas('defaults_elasticsearch').with(:notify => 'Service[elasticsearch]', :incl  => '/etc/sysconfig/elasticsearch', :changes => "set ES_GROUP 'root'\nset ES_JAVA_OPTS '\"-server -XX:+UseTLAB -XX:+CMSClassUnloadingEnabled\"'\nset ES_USER 'root'\n") }

          end

          context 'and set defaults via file param' do

            let (:params) {
              default_params.merge({
                :init_defaults_file => 'puppet:///path/to/elasticsearch.defaults'
              })
            }

            it { should contain_file('/etc/sysconfig/elasticsearch').with(:source => 'puppet:///path/to/elasticsearch.defaults', :notify => 'Service[elasticsearch]') }

          end

          context 'no service restart when defaults change' do

            let (:params) {
              default_params.merge({
                :init_defaults     => { 'ES_USER' => 'root', 'ES_GROUP' => 'root', 'ES_JAVA_OPTS' => '"-server -XX:+UseTLAB -XX:+CMSClassUnloadingEnabled"' },
                :restart_on_change => false
              })
            }

            it { should contain_augeas('defaults_elasticsearch').with(:incl => '/etc/sysconfig/elasticsearch', :changes => "set ES_GROUP 'root'\nset ES_JAVA_OPTS '\"-server -XX:+UseTLAB -XX:+CMSClassUnloadingEnabled\"'\nset ES_USER 'root'\n").without_notify }

          end

          context 'when its unmanaged do nothing with it' do

            let (:params) {
              default_params.merge({
                :status => 'unmanaged'
              })
            }

            it { should contain_service('elasticsearch').with(:ensure => nil, :enable => false) }

          end

        end

      end # Services

      context 'when setting the module to absent' do

         let (:params) {
           default_params.merge({
             :ensure => 'absent'
           })
         }

         it { should contain_file('/etc/elasticsearch').with(:ensure => 'absent', :force => true, :recurse => true) }
         it { should contain_package('elasticsearch').with(:ensure => 'purged') }
         it { should contain_service('elasticsearch').with(:ensure => 'stopped', :enable => false) }

      end

      context 'When managing the repository' do

        let (:params) {
          default_params.merge({
            :manage_repo => true,
            :repo_version => '1.0'
          })
        }

        it { should contain_class('elasticsearch::repo').that_requires('Anchor[elasticsearch::begin]') }
        it { should contain_exec('elasticsearch_suse_import_gpg') }
        it { should contain_zypprepo('elasticsearch').with(:baseurl => 'http://packages.elasticsearch.org/elasticsearch/1.0/centos') }

      end

    end

  end

end
