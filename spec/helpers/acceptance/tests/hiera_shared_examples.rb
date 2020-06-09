require 'tempfile'
require 'helpers/acceptance/tests/basic_shared_examples'
require 'helpers/acceptance/tests/plugin_shared_examples'

agents = only_host_with_role(hosts, 'agent')

shared_examples 'hiera tests with' do |es_config, additional_yaml = {}|
  hieradata = {
    'elasticsearch::config' => es_config
  }.merge(additional_yaml).to_yaml

  before :all do
    write_hieradata_to(agents, hieradata)
  end

  include_examples('basic acceptance tests', es_config)
end

shared_examples 'hiera acceptance tests' do |es_config, plugins|
  describe 'hiera', :then_purge do
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
        jvm_options => [
          '-Xms128m',
          '-Xmx128m',
        ],
        oss => #{v[:oss]},
        #{package}
      MANIFEST
    end

    let(:manifest_class_parameters) { 'restart_on_change => true' }

    describe 'with hieradata' do
      nodename = SecureRandom.hex(10)
      include_examples(
        'hiera tests with',
        es_config.merge('node.name' => nodename)
      )
    end

    plugins.each_pair do |plugin, _meta|
      describe "with plugin #{plugin}" do
        nodename = SecureRandom.hex(10)
        include_examples(
          'hiera tests with',
          es_config.merge('node.name' => nodename),
          'elasticsearch::plugins' => {
            plugin => {
              'ensure' => 'present'
            }
          }
        )

        include_examples(
          'plugin API response',
          es_config.merge('node.name' => nodename),
          'reports the plugin as installed',
          'name' => plugin
        )
      end
    end

    after :all do
      write_hieradata_to(agents, {})

      # Ensure that elasticsearch is cleaned up before any other tests
      cleanup_manifest = <<-EOS
        class { 'elasticsearch': ensure => 'absent', oss => #{v[:oss]} }
      EOS
      apply_manifest(cleanup_manifest, :debug => v[:puppet_debug])
    end
  end
end
