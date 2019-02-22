require 'json'
require 'helpers/acceptance/tests/basic_shared_examples'

shared_examples 'package_url acceptance tests' do
  describe 'elasticsearch::package_url' do
    instances =
      {
        'es-01' => {
          'config' => {
            'http.port' => 9200
          }
        }
      }

    context 'via http', :with_cleanup do
      let(:manifest) do
        <<-MANIFEST
          config => {
            'cluster.name' => '#{v[:cluster_name]}',
            'http.bind_host' => '0.0.0.0',
          },
          manage_repo => false,
          package_url => '#{v[:elasticsearch_package][:url]}'
        MANIFEST
      end

      include_examples 'basic acceptance tests', instances
    end

    context 'via local filesystem', :with_cleanup do
      before :all do
        scp_to default,
               v[:elasticsearch_package][:path],
               "/tmp/#{v[:elasticsearch_package][:filename]}"
      end

      let(:manifest) do
        <<-MANIFEST
          config => {
            'cluster.name' => '#{v[:cluster_name]}',
            'http.bind_host' => '0.0.0.0',
          },
          manage_repo => false,
          package_url => 'file:/tmp/#{v[:elasticsearch_package][:filename]}'
        MANIFEST
      end

      include_examples 'basic acceptance tests', instances
    end

    context 'via puppet paths', :with_cleanup do
      before :all do
        shell "mkdir -p #{default['distmoduledir']}/another/files"

        scp_to default,
               v[:elasticsearch_package][:path],
               "#{default['distmoduledir']}/another/files/#{v[:elasticsearch_package][:filename]}"
      end

      let(:manifest) do
        <<-MANIFEST
          config => {
            'cluster.name' => '#{v[:cluster_name]}',
            'http.bind_host' => '0.0.0.0',
          },
          manage_repo => false,
          package_url =>
            'puppet:///modules/another/#{v[:elasticsearch_package][:filename]}',
        MANIFEST
      end

      include_examples 'basic acceptance tests', instances
    end
  end
end
