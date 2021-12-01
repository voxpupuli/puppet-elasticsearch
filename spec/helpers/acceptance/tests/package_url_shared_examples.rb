# frozen_string_literal: true

require 'json'
require 'helpers/acceptance/tests/basic_shared_examples'

shared_examples 'package_url acceptance tests' do |es_config|
  describe 'elasticsearch::package_url' do
    # Override default manifest to remove `package`
    let(:manifest) do
      <<-MANIFEST
        api_timeout => 60,
        config => {
          'cluster.name' => '#{v[:cluster_name]}',
          'http.bind_host' => '0.0.0.0',
  #{es_config.map { |k, v| "        '#{k}' => '#{v}'," }.join("\n")}
        },
        jvm_options => [
          '-Xms128m',
          '-Xmx128m',
        ],
        oss => #{v[:oss]},
      MANIFEST
    end

    # context 'via http', :with_cleanup do
    context 'via http' do
      let(:manifest_class_parameters) do
        <<-MANIFEST
          manage_repo => false,
          package_url => '#{v[:elasticsearch_package][:url]}'
        MANIFEST
      end

      include_examples('basic acceptance tests', es_config)
    end

    context 'via local filesystem', :with_cleanup do
      before :all do # rubocop:disable RSpec/BeforeAfterAll
        scp_to default,
               v[:elasticsearch_package][:path],
               "/tmp/#{v[:elasticsearch_package][:filename]}"
      end

      let(:manifest_class_parameters) do
        <<-MANIFEST
          manage_repo => false,
          package_url => 'file:/tmp/#{v[:elasticsearch_package][:filename]}'
        MANIFEST
      end

      include_examples('basic acceptance tests', es_config)
    end

    context 'via puppet paths', :with_cleanup do
      before :all do # rubocop:disable RSpec/BeforeAfterAll
        shell "mkdir -p #{default['distmoduledir']}/another/files"

        scp_to default,
               v[:elasticsearch_package][:path],
               "#{default['distmoduledir']}/another/files/#{v[:elasticsearch_package][:filename]}"
      end

      let(:manifest_class_parameters) do
        <<-MANIFEST
          manage_repo => false,
          package_url => 'puppet:///modules/another/#{v[:elasticsearch_package][:filename]}',
        MANIFEST
      end

      include_examples('basic acceptance tests', es_config)
    end
  end
end
