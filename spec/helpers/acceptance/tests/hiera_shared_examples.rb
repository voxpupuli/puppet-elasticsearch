# frozen_string_literal: true

require 'tempfile'
require 'helpers/acceptance/tests/basic_shared_examples'
require 'helpers/acceptance/tests/plugin_shared_examples'

agents = only_host_with_role(hosts, 'agent')

shared_examples 'hiera tests with' do |es_config, additional_yaml = {}|
  hieradata = {
    'elasticsearch::config' => es_config
  }.merge(additional_yaml).to_yaml

  before :all do # rubocop:disable RSpec/BeforeAfterAll
    write_hieradata_to(agents, hieradata)
  end

  include_examples('basic acceptance tests', es_config)
end

shared_examples 'hiera acceptance tests' do |es_config, plugins|
  describe 'hiera', :then_purge do
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

    after :all do # rubocop:disable RSpec/BeforeAfterAll
      write_hieradata_to(agents, {})

      # Ensure that elasticsearch is cleaned up before any other tests
      cleanup_manifest = <<-EOS
        class { 'elasticsearch': ensure => 'absent', oss => #{v[:oss]} }
      EOS
      apply_manifest(cleanup_manifest, debug: v[:puppet_debug])
    end

    describe 'with hieradata' do
      # Remove leading 0: 01234567 is valid octal, but 89abcdef is not and the
      # serialisation will cause trouble for the test suite (quoting the value?).
      nodename = SecureRandom.hex(10).sub(%r{^0+}, '')
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
  end
end
