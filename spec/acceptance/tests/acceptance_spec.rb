require 'spec_helper_acceptance'
require 'helpers/acceptance/tests/basic_shared_examples.rb'
require 'helpers/acceptance/tests/template_shared_examples.rb'
require 'helpers/acceptance/tests/removal_shared_examples.rb'
require 'helpers/acceptance/tests/plugin_shared_examples.rb'
require 'helpers/acceptance/tests/snapshot_repository_shared_examples.rb'
require 'helpers/acceptance/tests/datadir_shared_examples.rb'
require 'helpers/acceptance/tests/package_url_shared_examples.rb'
require 'helpers/acceptance/tests/hiera_shared_examples.rb'
require 'helpers/acceptance/tests/usergroup_shared_examples.rb'
require 'helpers/acceptance/tests/shield_shared_examples.rb'

describe "elasticsearch v#{v[:elasticsearch_full_version]} class" do
  local_plugin_path = Dir[
    "#{test_settings['files_dir']}/elasticsearch-plugin-2*"
  ].first
  local_plugin_name = File.basename(local_plugin_path).split('_').last.split('.').first

  let(:manifest) do
    <<-MANIFEST
      config => {
        'cluster.name' => '#{v[:cluster_name]}',
        'network.host' => '0.0.0.0',
      },
      repo_version => '#{v[:elasticsearch_major_version]}.x',
      # Hard version set here due to plugin incompatibilities.
      version => '#{v[:elasticsearch_full_version]}',
    MANIFEST
  end

  context 'instance testing with' do
    describe 'one' do
      include_examples(
        'basic acceptance tests',
        'es-01' => {
          'http.port' => 9200,
          'node.name' => 'elasticsearch001'
        }
      )
    end

    describe 'two' do
      include_examples(
        'basic acceptance tests',
        'es-01' => {
          'http.port' => 9200,
          'node.name' => 'elasticsearch001'
        },
        'es-02' => {
          'http.port' => 9201,
          'node.name' => 'elasticsearch002'
        }
      )
    end

    describe 'one absent' do
      include_examples(
        'basic acceptance tests',
        'es-01' => {
          'http.port' => 9200,
          'node.name' => 'elasticsearch001'
        },
        'es-02' => {}
      )
    end

    include_examples 'module removal', ['es-01']
  end

  include_examples(
    'template operations',
    {
      'es-01' => {
        'http.port' => 9200,
        'node.name' => 'elasticsearch001'
      }
    },
    test_settings['template']
  )

  context 'with restart_on_changes' do
    let(:manifest_class_parameters) { 'restart_on_change => true' }

    include_examples(
      'plugin acceptance tests',
      {
        'es-01' => {
          'http.port' => 9200,
          'node.name' => 'elasticsearch001'
        }
      },
      :github => {
        :name => 'kopf',
        :initial => '2.0.1',
        :upgraded => '2.1.2',
        :repository => 'lmenezes/elasticsearch-'
      },
      :official => 'analysis-icu',
      :offline => {
        :name => local_plugin_name,
        :path => local_plugin_path
      },
      :remote => {
        :url => 'https://github.com/royrusso/elasticsearch-HQ/archive/v2.0.3.zip',
        :name => 'hq'
      }
    )
  end

  include_examples 'snapshot repository acceptance tests'

  include_examples 'datadir acceptance tests'

  include_examples 'package_url acceptance tests'

  include_examples 'hiera acceptance tests'

  include_examples 'user/group acceptance tests'

  # Security-related tests (shield/x-pack)
  if semver(v[:elasticsearch_full_version]) < semver('5.0.0')
    include_examples 'shield acceptance tests'
  end
end
