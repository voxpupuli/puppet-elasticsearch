# frozen_string_literal: true

require 'spec_helper'

describe 'elasticsearch::license', type: 'class' do
  # First, randomly select one of our supported OSes to run tests that apply
  # to any distro
  on_supported_os.to_a.sample(1).to_h.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge('scenario' => '', 'common' => '')
      end

      context 'when managing x-pack license' do
        let(:params) do
          {
            content: {
              'license' => {
                'uid' => 'cbff45e7-c553-41f7-ae4f-9205eabd80xx',
                'type' => 'trial',
                'issue_date_in_millis' => 1_519_341_125_550,
                'expiry_date_in_millis' => 1_521_933_125_550,
                'max_nodes' => 1000,
                'issued_to' => 'test',
                'issuer' => 'elasticsearch',
                'signature' => 'secretvalue',
                'start_date_in_millis' => 1_513_814_400_000
              }
            }
          }
        end

        let(:pre_condition) do
          <<-EOS
            class { 'elasticsearch' :
              api_protocol            => 'https',
              api_host                => '127.0.0.1',
              api_port                => 9201,
              api_timeout             => 11,
              api_basic_auth_username => 'elastic',
              api_basic_auth_password => 'password',
              api_ca_file             => '/foo/bar.pem',
              api_ca_path             => '/foo/',
              validate_tls            => false,
            }
          EOS
        end

        it do
          expect(subject).to contain_class('elasticsearch::license')
        end

        it do
          expect(subject).to contain_es_instance_conn_validator(
            'license-conn-validator'
          ).that_comes_before('elasticsearch_license[xpack]')
        end

        it do
          expect(subject).to contain_elasticsearch_license('xpack').with(
            ensure: 'present',
            content: {
              'license' => {
                'uid' => 'cbff45e7-c553-41f7-ae4f-9205eabd80xx',
                'type' => 'trial',
                'issue_date_in_millis' => 1_519_341_125_550,
                'expiry_date_in_millis' => 1_521_933_125_550,
                'max_nodes' => 1000,
                'issued_to' => 'test',
                'issuer' => 'elasticsearch',
                'signature' => 'secretvalue',
                'start_date_in_millis' => 1_513_814_400_000
              }
            },
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
    end
  end
end
