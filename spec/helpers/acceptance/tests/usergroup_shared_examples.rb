# frozen_string_literal: true

require 'json'
require 'helpers/acceptance/tests/basic_shared_examples'

shared_examples 'user/group acceptance tests' do
  describe 'user/group parameters', first_purge: true, then_purge: true do
    describe 'with non-default values', :with_cleanup do
      let(:extra_manifest) do
        <<-MANIFEST
          group { 'esuser':
            ensure => 'present',
          } -> group { 'esgroup':
            ensure => 'present'
          } -> user { 'esuser':
            ensure => 'present',
            groups => ['esgroup', 'esuser'],
            before => Class['elasticsearch'],
          }
        MANIFEST
      end

      let(:manifest_class_parameters) do
        <<-MANIFEST
          elasticsearch_user => 'esuser',
          elasticsearch_group => 'esgroup',
        MANIFEST
      end

      include_examples(
        'basic acceptance tests',
        'es-01' => {
          'config' => {
            'http.port' => 9200,
            'node.name' => 'elasticsearch001'
          }
        }
      )

      %w[
        /etc/elasticsearch/es-01/elasticsearch.yml
        /usr/share/elasticsearch
        /var/log/elasticsearch
      ].each do |path|
        describe file(path) do
          it { is_expected.to be_owned_by 'esuser' }
        end
      end
    end
  end
end
