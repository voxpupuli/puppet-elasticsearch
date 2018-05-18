require 'json'
require 'helpers/acceptance/tests/bad_manifest_shared_examples'
require 'helpers/acceptance/tests/manifest_shared_examples'
require 'helpers/acceptance/tests/plugin_api_shared_examples'

shared_examples 'plugin acceptance tests' do |plugins|
  describe 'elasticsearch::plugin' do
    instances = {
      'es-01' => {
        'config' => {
          'http.port' => 9200,
          'node.name' => 'elasticsearch001'
        }
      }
    }

    describe 'invalid plugins', :with_cleanup do
      let(:extra_manifest) do
        <<-MANIFEST
          elasticsearch::plugin { 'elastic/non-existing':
            instances => 'es-01',
          }
        MANIFEST
      end

      include_examples(
        'invalid manifest application',
        instances
      )
    end

    before :all do
      shell "mkdir -p #{default['distmoduledir']}/another/files"
    end

    plugins.each_pair do |plugin, meta|
      describe plugin do
        # Ensure that instances are restarted to include plugins
        let(:manifest_class_parameters) { 'restart_on_change => true' }

        describe 'installation' do
          describe 'using simple names', :with_cleanup do
            let(:extra_manifest) do
              <<-MANIFEST
                elasticsearch::plugin { '#{plugin}':
                  instances => 'es-01',
                }
              MANIFEST
            end

            include_examples(
              'manifest application',
              instances
            )

            describe file("/usr/share/elasticsearch/plugins/#{plugin}/") do
              it { should be_directory }
            end

            include_examples(
              'plugin API response',
              instances,
              'reports the plugin as installed',
              'name' => plugin
            )
          end

          describe 'offline via puppet://', :with_cleanup do
            before :all do
              scp_to(
                default,
                meta[:path],
                "#{default['distmoduledir']}/another/files/#{plugin}.zip"
              )
            end

            let(:extra_manifest) do
              <<-MANIFEST
                elasticsearch::plugin { '#{plugin}':
                  instances => 'es-01',
                  source    => 'puppet:///modules/another/#{plugin}.zip',
                }
              MANIFEST
            end

            include_examples(
              'manifest application',
              instances
            )

            include_examples(
              'plugin API response',
              instances,
              'reports the plugin as installed',
              'name' => plugin
            )
          end

          describe 'via url', :with_cleanup do
            let(:extra_manifest) do
              <<-MANIFEST
                elasticsearch::plugin { '#{plugin}':
                  instances => 'es-01',
                  url       => '#{meta[:url]}',
                }
              MANIFEST
            end

            include_examples(
              'manifest application',
              instances
            )

            include_examples(
              'plugin API response',
              instances,
              'reports the plugin as installed',
              'name' => plugin
            )
          end
        end
      end
    end
  end
end
