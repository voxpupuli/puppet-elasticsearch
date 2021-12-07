# frozen_string_literal: true

require 'json'
require 'helpers/acceptance/tests/bad_manifest_shared_examples'
require 'helpers/acceptance/tests/manifest_shared_examples'
require 'helpers/acceptance/tests/plugin_api_shared_examples'

shared_examples 'plugin acceptance tests' do |es_config, plugins|
  describe 'elasticsearch::plugin' do
    before :all do # rubocop:disable RSpec/BeforeAfterAll
      shell "mkdir -p #{default['distmoduledir']}/another/files"
    end

    describe 'invalid plugins', :with_cleanup do
      let(:extra_manifest) do
        <<-MANIFEST
          elasticsearch::plugin { 'elastic/non-existing': }
        MANIFEST
      end

      include_examples('invalid manifest application')
    end

    plugins.each_pair do |plugin, meta|
      describe plugin do
        # Ensure that instances are restarted to include plugins
        let(:manifest_class_parameters) { 'restart_on_change => true' }

        describe 'installation' do
          describe 'using simple names', :with_cleanup do
            let(:extra_manifest) do
              <<-MANIFEST
                elasticsearch::plugin { '#{plugin}': }
              MANIFEST
            end

            include_examples('manifest application', es_config)

            describe file("/usr/share/elasticsearch/plugins/#{plugin}/") do
              it { is_expected.to be_directory }
            end

            include_examples(
              'plugin API response',
              es_config,
              'reports the plugin as installed',
              'name' => plugin
            )
          end

          describe 'offline via puppet://', :with_cleanup do
            before :all do # rubocop:disable RSpec/BeforeAfterAll
              scp_to(
                default,
                meta[:path],
                "#{default['distmoduledir']}/another/files/#{plugin}.zip"
              )
            end

            let(:extra_manifest) do
              <<-MANIFEST
                elasticsearch::plugin { '#{plugin}':
                  source => 'puppet:///modules/another/#{plugin}.zip',
                }
              MANIFEST
            end

            include_examples('manifest application', es_config)

            include_examples(
              'plugin API response',
              es_config,
              'reports the plugin as installed',
              'name' => plugin
            )
          end

          describe 'via url', :with_cleanup do
            let(:extra_manifest) do
              <<-MANIFEST
                elasticsearch::plugin { '#{plugin}':
                  url => '#{meta[:url]}',
                }
              MANIFEST
            end

            include_examples('manifest application', es_config)

            include_examples(
              'plugin API response',
              es_config,
              'reports the plugin as installed',
              'name' => plugin
            )
          end
        end
      end
    end
  end
end
