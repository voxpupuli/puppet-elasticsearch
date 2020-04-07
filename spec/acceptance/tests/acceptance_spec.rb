require 'spec_helper_acceptance'
require 'helpers/acceptance/tests/basic_shared_examples.rb'
require 'helpers/acceptance/tests/template_shared_examples.rb'
require 'helpers/acceptance/tests/removal_shared_examples.rb'
require 'helpers/acceptance/tests/pipeline_shared_examples.rb'
require 'helpers/acceptance/tests/plugin_shared_examples.rb'
require 'helpers/acceptance/tests/plugin_upgrade_shared_examples.rb'
require 'helpers/acceptance/tests/snapshot_repository_shared_examples.rb'
require 'helpers/acceptance/tests/datadir_shared_examples.rb'
require 'helpers/acceptance/tests/package_url_shared_examples.rb'
require 'helpers/acceptance/tests/hiera_shared_examples.rb'
require 'helpers/acceptance/tests/usergroup_shared_examples.rb'
require 'helpers/acceptance/tests/security_shared_examples.rb'

describe "elasticsearch v#{v[:elasticsearch_full_version]} class" do
  es_config = {
    'http.port' => 9200,
    'node.name' => 'elasticsearch01'
  }

  let(:elastic_repo) { not v[:is_snapshot] }
  let(:manifest) do
    package = if not v[:is_snapshot]
                <<-MANIFEST
                  # Hard version set here due to plugin incompatibilities.
                  version => '#{v[:elasticsearch_full_version]}',
                MANIFEST
              else
                <<-MANIFEST
                  manage_repo => false,
                  package_url => '#{v[:snapshot_package]}',
                MANIFEST
              end

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
      #{package}
    MANIFEST
  end

  context 'testing with' do
    describe 'simple config' do
      include_examples('basic acceptance tests', es_config)
    end

    include_examples('module removal', es_config)
  end

  include_examples('template operations', es_config, v[:template])

  include_examples('pipeline operations', es_config, v[:pipeline])

  include_examples('plugin acceptance tests', es_config, v[:elasticsearch_plugins]) unless v[:elasticsearch_plugins].empty?

  # # Only pre-5.x versions supported versions differing from core ES
  # if semver(v[:elasticsearch_full_version]) < semver('5.0.0')
  #   include_examples(
  #     'plugin upgrade acceptance tests',
  #     :name => 'kopf',
  #     :initial => '2.0.1',
  #     :upgraded => '2.1.2',
  #     :repository => 'lmenezes/elasticsearch'
  #   )
  # end

  include_examples('snapshot repository acceptance tests')

  include_examples('datadir acceptance tests', es_config)

  # # Skip this for snapshot testing, as we only have package files anyway.
  # include_examples 'package_url acceptance tests' unless v[:is_snapshot]

  # include_examples 'hiera acceptance tests', v[:elasticsearch_plugins]

  # include_examples 'user/group acceptance tests'

  # # Security-related tests (shield/x-pack).
  # #
  # # Skip OSS-only distributions since they do not bundle x-pack, and skip
  # # snapshots since we they don't recognize prod licenses.
  # include_examples 'security acceptance tests', instances unless v[:oss] or v[:is_snapshot]
end
