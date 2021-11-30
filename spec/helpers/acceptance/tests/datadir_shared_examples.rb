# frozen_string_literal: true

require 'json'
require 'helpers/acceptance/tests/manifest_shared_examples'

shared_examples 'datadir directory validation' do |es_config, datapaths|
  include_examples('manifest application')

  describe file('/etc/elasticsearch/elasticsearch.yml') do
    it { is_expected.to be_file }

    datapaths.each do |datapath|
      it { is_expected.to contain datapath }
    end
  end

  datapaths.each do |datapath|
    describe file(datapath) do
      it { is_expected.to be_directory }
    end
  end

  es_port = es_config['http.port']
  describe port(es_port) do
    it 'open', :with_retries do
      expect(subject).to be_listening
    end
  end

  describe "http://localhost:#{es_port}/_nodes/_local" do
    subject { shell("curl http://localhost:#{es_port}/_nodes/_local") }

    it 'uses a custom data path' do
      json = JSON.parse(subject.stdout)['nodes'].values.first
      expect(
        json['settings']['path']['data']
      ).to(datapaths.one? && v[:elasticsearch_major_version] <= 2 ? eq(datapaths.first) : contain_exactly(*datapaths))
    end
  end
end

shared_examples 'datadir acceptance tests' do |es_config|
  describe 'elasticsearch::datadir' do
    let(:manifest_class_parameters) { 'restart_on_change => true' }

    context 'single path', :with_cleanup do
      let(:manifest_class_parameters) do
        <<-MANIFEST
          datadir           => '/var/lib/elasticsearch-data',
          restart_on_change => true,
        MANIFEST
      end

      include_examples('datadir directory validation',
                       es_config,
                       ['/var/lib/elasticsearch-data'])
    end

    context 'multiple paths', :with_cleanup do
      let(:manifest_class_parameters) do
        <<-MANIFEST
          datadir => [
            '/var/lib/elasticsearch-01',
            '/var/lib/elasticsearch-02'
          ],
          restart_on_change => true,
        MANIFEST
      end

      include_examples('datadir directory validation',
                       es_config,
                       ['/var/lib/elasticsearch-01', '/var/lib/elasticsearch-02'])
    end
  end
end
