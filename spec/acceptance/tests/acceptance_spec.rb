require 'spec_helper_acceptance'
require 'helpers/acceptance/tests/basic_shared_examples.rb'
require 'helpers/acceptance/tests/template_shared_examples.rb'
require 'helpers/acceptance/tests/removal_shared_examples.rb'
require 'helpers/acceptance/tests/plugin_shared_examples.rb'
require 'helpers/acceptance/tests/plugin_upgrade_shared_examples.rb'
require 'helpers/acceptance/tests/snapshot_repository_shared_examples.rb'
require 'helpers/acceptance/tests/datadir_shared_examples.rb'
require 'helpers/acceptance/tests/package_url_shared_examples.rb'
require 'helpers/acceptance/tests/hiera_shared_examples.rb'
require 'helpers/acceptance/tests/usergroup_shared_examples.rb'
require 'helpers/acceptance/tests/security_shared_examples.rb'

describe "elasticsearch v#{v[:elasticsearch_full_version]} class" do
  es_01 = {
    'es-01' => {
      'config' => {
        'http.port' => 9200,
        'node.name' => 'elasticsearch001'
      }
    }
  }
  es_02 = {
    'es-02' => {
      'config' => {
        'http.port' => 9201,
        'node.name' => 'elasticsearch002'
      }
    }
  }
  instances = es_01.merge es_02

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
      include_examples('basic acceptance tests', es_01)
    end

    describe 'two' do
      include_examples('basic acceptance tests', instances)
    end

    describe 'one absent' do
      include_examples('basic acceptance tests', es_01.merge('es-02' => {}))
    end

    include_examples 'module removal', ['es-01']
  end

  include_examples('template operations', es_01, v[:template])

  include_examples('plugin acceptance tests', v[:elasticsearch_plugins])

  # Only pre-5.x versions supported versions differing from core ES
  if semver(v[:elasticsearch_full_version]) < semver('5.0.0')
    include_examples(
      'plugin upgrade acceptance tests',
      :name => 'kopf',
      :initial => '2.0.1',
      :upgraded => '2.1.2',
      :repository => 'lmenezes/elasticsearch'
    )
  end

  include_examples 'snapshot repository acceptance tests'

  include_examples 'datadir acceptance tests'

  include_examples 'package_url acceptance tests'

  include_examples 'hiera acceptance tests', v[:elasticsearch_plugins]

  include_examples 'user/group acceptance tests'

  # Security-related tests (shield/x-pack)
  include_examples 'security acceptance tests', instances
end
