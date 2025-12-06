# frozen_string_literal: true

require 'spec_helper'
require 'helpers/class_shared_examples'

describe 'elasticsearch::user' do
  let(:title) { 'elastic' }

  let(:pre_condition) do
    <<-EOS
      class { 'elasticsearch': }
    EOS
  end

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts.merge(
          scenario: '',
          common: ''
        )
      end

      context 'with default parameters' do
        let(:params) do
          {
            password: 'foobar',
            roles: %w[monitor user]
          }
        end

        it { is_expected.to contain_elasticsearch__user('elastic') }
        it { is_expected.to contain_elasticsearch_user('elastic') }

        it do
          expect(subject).to contain_elasticsearch_user_roles('elastic').with(
            'ensure' => 'present',
            'roles' => %w[monitor user]
          )
        end
      end

      context 'ensure absent without password' do
        let(:params) do
          {
            ensure: 'absent'
          }
        end

        it { is_expected.to compile }
        it { is_expected.to contain_elasticsearch_user('elastic').with_ensure('absent') }
      end

      context 'ensure present without password' do
        let(:params) do
          {
            ensure: 'present'
          }
        end

        it { is_expected.to compile.and_raise_error(%r{Password must be specified}) }
      end

      describe 'collector ordering' do
        let(:pre_condition) do
          <<-EOS
            class { 'elasticsearch': }
            elasticsearch::template { 'foo': content => {"foo" => "bar"} }
            elasticsearch::role { 'test_role':
              privileges => {
                'cluster' => 'monitor',
                'indices' => {
                  '*' => 'all',
                },
              },
            }
          EOS
        end

        let(:params) do
          {
            password: 'foobar',
            roles: %w[monitor user]
          }
        end

        it { is_expected.to contain_elasticsearch__role('test_role') }
        it { is_expected.to contain_elasticsearch_role('test_role') }
        it { is_expected.to contain_elasticsearch_role_mapping('test_role') }

        it {
          expect(subject).to contain_elasticsearch__user('elastic').
            that_comes_before([
                                'Elasticsearch::Template[foo]'
                              ]).that_requires([
                                                 'Elasticsearch::Role[test_role]'
                                               ])
        }

        include_examples 'class', :systemd
      end
    end
  end
end
