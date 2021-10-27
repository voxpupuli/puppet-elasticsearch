# frozen_string_literal: true

require 'spec_helper'

describe 'elasticsearch::script', type: 'define' do
  let(:title) { 'foo' }
  let(:pre_condition) do
    %(
      class { "elasticsearch":
        config => {
          "node" => {"name" => "test" }
        }
      }
    )
  end

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

      describe 'missing parent class' do
        it { is_expected.not_to compile }
      end

      describe 'adding script files' do
        let(:params) do
          {
            ensure: 'present',
            source: 'puppet:///path/to/foo.groovy'
          }
        end

        it { is_expected.to contain_elasticsearch__script('foo') }

        it {
          expect(subject).to contain_file('/usr/share/elasticsearch/scripts/foo.groovy').
            with(
              source: 'puppet:///path/to/foo.groovy',
              ensure: 'present'
            )
        }
      end

      describe 'adding script directories' do
        let(:params) do
          {
            ensure: 'directory',
            source: 'puppet:///path/to/my_scripts',
            recurse: 'remote'
          }
        end

        it { is_expected.to contain_elasticsearch__script('foo') }

        it {
          expect(subject).to contain_file(
            '/usr/share/elasticsearch/scripts/my_scripts'
          ).with(
            ensure: 'directory',
            source: 'puppet:///path/to/my_scripts',
            recurse: 'remote'
          )
        }
      end

      describe 'removing scripts' do
        let(:params) do
          {
            ensure: 'absent',
            source: 'puppet:///path/to/foo.groovy'
          }
        end

        it { is_expected.to contain_elasticsearch__script('foo') }

        it {
          expect(subject).to contain_file('/usr/share/elasticsearch/scripts/foo.groovy').
            with(
              source: 'puppet:///path/to/foo.groovy',
              ensure: 'absent'
            )
        }
      end
    end
  end
end
