# frozen_string_literal: true

require 'spec_helper'

describe 'elasticsearch::snapshot_repository', type: 'define' do
  on_supported_os(
    hardwaremodels: ['x86_64'],
    supported_os: [
      {
        'operatingsystem' => 'CentOS',
        'operatingsystemrelease' => ['6']
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

      let(:title) { 'backup' }
      let(:pre_condition) do
        'class { "elasticsearch" : }'
      end

      describe 'parameter validation' do
        %i[api_ca_file api_ca_path].each do |param|
          let :params do
            {
              :ensure => 'present',
              :content => '{}',
              param => 'foo/cert'
            }
          end

          it 'validates cert paths' do
            expect(subject).to compile.and_raise_error(%r{expects a})
          end
        end

        describe 'missing parent class' do
          it { is_expected.not_to compile }
        end
      end

      describe 'template from source' do
        let :params do
          {
            ensure: 'present',
            location: '/var/lib/elasticsearch/backup',
            api_protocol: 'https',
            api_host: '127.0.0.1',
            api_port: 9201,
            api_timeout: 11,
            api_basic_auth_username: 'elastic',
            api_basic_auth_password: 'password',
            validate_tls: false
          }
        end

        it { is_expected.to contain_elasticsearch__snapshot_repository('backup') }

        it do
          expect(subject).to contain_es_instance_conn_validator('backup-snapshot').
            that_comes_before('Elasticsearch_snapshot_repository[backup]')
        end

        it 'passes through parameters' do
          expect(subject).to contain_elasticsearch_snapshot_repository('backup').with(
            ensure: 'present',
            location: '/var/lib/elasticsearch/backup',
            protocol: 'https',
            host: '127.0.0.1',
            port: 9201,
            timeout: 11,
            username: 'elastic',
            password: 'password',
            validate_tls: false
          )
        end
      end

      describe 'class parameter inheritance' do
        let :params do
          {
            ensure: 'present',
            location: '/var/lib/elasticsearch/backup'
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
          expect(subject).to contain_elasticsearch_snapshot_repository('backup').with(
            ensure: 'present',
            location: '/var/lib/elasticsearch/backup',
            protocol: 'https',
            host: '127.0.0.1',
            port: 9201,
            timeout: 11,
            username: 'elastic',
            password: 'password',
            ca_file: '/foo/bar.pem',
            ca_path: '/foo/',
            validate_tls: false
          )
        end
      end

      describe 'snapshot repository deletion' do
        let :params do
          {
            ensure: 'absent',
            location: '/var/lib/elasticsearch/backup'
          }
        end

        it 'removes snapshot repository' do
          expect(subject).to contain_elasticsearch_snapshot_repository('backup').with(ensure: 'absent')
        end
      end
    end
  end
end
