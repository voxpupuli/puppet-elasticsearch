# frozen_string_literal: true

require 'json'
require 'helpers/acceptance/tests/manifest_shared_examples'

shared_examples 'basic acceptance tests' do |es_config|
  include_examples('manifest application')

  describe package("elasticsearch#{v[:oss] ? '-oss' : ''}") do
    it {
      expect(subject).to be_installed.
        with_version(v[:elasticsearch_full_version])
    }
  end

  %w[
    /etc/elasticsearch
    /usr/share/elasticsearch
    /var/lib/elasticsearch
  ].each do |dir|
    describe file(dir) do
      it { is_expected.to be_directory }
    end
  end

  describe 'resources' do
    describe service('elasticsearch') do
      it { send(es_config.empty? ? :should_not : :should, be_enabled) }
      it { send(es_config.empty? ? :should_not : :should, be_running) }
    end

    unless es_config.empty?
      describe file(pid_file) do
        it { is_expected.to be_file }
        its(:content) { is_expected.to match(%r{[0-9]+}) }
      end

      describe file('/etc/elasticsearch/elasticsearch.yml') do
        it { is_expected.to be_file }
        it { is_expected.to contain "name: #{es_config['node.name']}" }
      end
    end

    unless es_config.empty?
      es_port = es_config['http.port']
      describe port(es_port) do
        it 'open', :with_retries do
          expect(subject).to be_listening
        end
      end

      describe "http://localhost:#{es_port}/_nodes/_local" do
        subject { shell("curl http://localhost:#{es_port}/_nodes/_local") }

        it 'serves requests', :with_retries do
          expect(subject.exit_code).to eq(0)
        end

        it 'uses the default data path', :with_retries do
          json = JSON.parse(subject.stdout)['nodes'].values.first
          data_dir = ['/var/lib/elasticsearch']
          expect(
            json['settings']['path']
          ).to include(
            'data' => data_dir
          )
        end
      end
    end
  end
end
