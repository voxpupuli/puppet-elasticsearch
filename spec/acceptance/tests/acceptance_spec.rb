# frozen_string_literal: true

require 'spec_helper_acceptance'
require 'helpers/acceptance/tests/basic_shared_examples'
require 'helpers/acceptance/tests/template_shared_examples'
require 'helpers/acceptance/tests/removal_shared_examples'
require 'helpers/acceptance/tests/pipeline_shared_examples'
require 'helpers/acceptance/tests/plugin_shared_examples'
require 'helpers/acceptance/tests/plugin_upgrade_shared_examples'
require 'helpers/acceptance/tests/snapshot_repository_shared_examples'
require 'helpers/acceptance/tests/datadir_shared_examples'
require 'helpers/acceptance/tests/package_url_shared_examples'
require 'helpers/acceptance/tests/hiera_shared_examples'
require 'helpers/acceptance/tests/usergroup_shared_examples'
require 'helpers/acceptance/tests/security_shared_examples'

describe "elasticsearch v#{v[:elasticsearch_full_version]} class" do
  es_config = {
    'cluster.name' => v[:cluster_name],
    'http.bind_host' => '0.0.0.0',
    'http.port' => 9200,
    'node.name' => 'elasticsearch01'
  }

  let(:elastic_repo) { !v[:is_snapshot] }
  let(:manifest) do
    package = if v[:is_snapshot]
                <<-MANIFEST
                  manage_repo => false,
                  package_url => '#{v[:snapshot_package]}',
                MANIFEST
              else
                <<-MANIFEST
                  # Hard version set here due to plugin incompatibilities.
                  version => '#{v[:elasticsearch_full_version]}',
                MANIFEST
              end

    <<~MANIFEST
            api_timeout => 60,
            config => {
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

  unless v[:elasticsearch_plugins].empty?
    include_examples(
      'plugin acceptance tests',
      es_config,
      v[:elasticsearch_plugins]
    )
  end

  include_examples('snapshot repository acceptance tests')

  include_examples('datadir acceptance tests', es_config)

  # Skip this for snapshot testing, as we only have package files anyway.
  include_examples('package_url acceptance tests', es_config) unless v[:is_snapshot]

  include_examples('hiera acceptance tests', es_config, v[:elasticsearch_plugins])

  # Security-related tests (shield/x-pack).
  #
  # Skip OSS-only distributions since they do not bundle x-pack, and skip
  # snapshots since we they don't recognize prod licenses.
  include_examples('security acceptance tests', es_config) unless v[:oss] || v[:is_snapshot]
end
