require 'spec_helper'

describe 'elasticsearch::snapshot_lifecycle_policy', :type => 'define' do
  on_supported_os(
    :hardwaremodels => ['x86_64'],
    :supported_os => [
      {
        'operatingsystem' => 'CentOS',
        'operatingsystemrelease' => ['6']
      }
    ]
  ).each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts.merge(
        :scenario => '',
        :common => ''
      ) }

      let(:title) { 'policy' }
      let(:pre_condition) do
        'class { "elasticsearch" : }'
      end

      describe 'parameter validation' do
        [:api_ca_file, :api_ca_path].each do |param|
          let :params do
            {
              :ensure => 'present',
              :content => '{}',
              param => 'foo/cert'
            }
          end

          it 'validates cert paths' do
            is_expected.to compile.and_raise_error(/expects a/)
          end
        end

        describe 'missing parent class' do
          let(:pre_condition) {}
          it { should_not compile }
        end
      end

      describe 'template from source' do
        let :params do
          {
            :ensure                  => 'present',
            :schedule_time           => '0 30 1 * * ?',
            :repository              => 'my_repository',
            :api_protocol            => 'https',
            :api_host                => '127.0.0.1',
            :api_port                => 9201,
            :api_timeout             => 11,
            :api_basic_auth_username => 'elastic',
            :api_basic_auth_password => 'password',
            :validate_tls            => false
          }
        end

        it { should contain_elasticsearch__snapshot_lifecycle_policy('policy') }
        it do
          should contain_es_instance_conn_validator('backup-snapshot_lifecycle_policy')
            .that_comes_before('Elasticsearch_snapshot_lifecycle_policy[policy]')
        end
        it 'passes through parameters' do
          should contain_elasticsearch_snapshot_lifecycle_policy('policy').with(
            :ensure        => 'present',
            :schedule_time => '0 30 1 * * ?',
            :repository    => 'my_repository',
            :protocol      => 'https',
            :host          => '127.0.0.1',
            :port          => 9201,
            :timeout       => 11,
            :username      => 'elastic',
            :password      => 'password',
            :validate_tls  => false
          )
        end
      end

      describe 'class parameter inheritance' do
        let :params do
          {
            :ensure        => 'present',
            :schedule_time => '0 30 1 * * ?',
            :repository    => 'my_repository'
          }
        end
        let(:pre_condition) do
          <<-MANIFEST
            class { 'elasticsearch' :
              api_protocol => 'https',
              api_host => '127.0.0.1',
              api_port => 9201,
              api_timeout => 11,
              api_basic_auth_username => 'elastic',
              api_basic_auth_password => 'password',
              api_ca_file => '/foo/bar.pem',
              api_ca_path => '/foo/',
              validate_tls => false,
            }
          MANIFEST
        end

        it do
          should contain_elasticsearch_snapshot_lifecycle_policy('policy').with(
            :ensure        => 'present',
            :schedule_time => '0 30 1 * * ?',
            :repository    => 'my_repository',
            :protocol      => 'https',
            :host          => '127.0.0.1',
            :port          => 9201,
            :timeout       => 11,
            :username      => 'elastic',
            :password      => 'password',
            :ca_file       => '/foo/bar.pem',
            :ca_path       => '/foo/',
            :validate_tls  => false
          )
        end
      end

      describe 'snapshot repository deletion' do
        let :params do
          {
            :ensure        => 'absent',
            :schedule_time => '0 30 1 * * ?',
            :repository    => 'my_repository'
          }
        end

        it 'removes snapshot lifecycle policy' do
          should contain_elasticsearch_snapshot_repository('policy').with(:ensure => 'absent')
        end
      end
    end
  end
end
