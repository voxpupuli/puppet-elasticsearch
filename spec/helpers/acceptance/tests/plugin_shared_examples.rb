require 'json'
require 'helpers/acceptance/tests/bad_manifest_shared_examples'
require 'helpers/acceptance/tests/manifest_shared_examples'

shared_examples 'plugin API response' do |instances, desc, val|
  instances.each_pair do |_instance, config|
    describe port(config['http.port']) do
      it 'open', :with_retries do
        should be_listening
      end
    end

    describe server :container do
      describe http(
        "http://localhost:#{config['http.port']}/_cluster/stats"
      ) do
        it desc, :with_retries do
          expect(
            JSON.parse(response.body)['nodes']['plugins']
          ).to include(include(val))
        end
      end
    end
  end
end

shared_examples 'plugin acceptance tests' do |instances, plugins|
  describe 'elasticsearch::plugin' do
    describe 'installation' do
      context 'using simple names', :with_cleanup do
        let(:extra_manifest) do
          <<-MANIFEST
            elasticsearch::plugin { '#{plugins[:official]}':
              instances => 'es-01',
            }
          MANIFEST
        end
        include_examples(
          'manifest application',
          instances
        )

        describe file("/usr/share/elasticsearch/plugins/#{plugins[:official]}/") do
          it { should be_directory }
        end

        include_examples(
          'plugin API response',
          instances,
          'reports the plugin as installed',
          'name' => plugins[:official]
        )
      end

      context 'invalid plugins', :with_cleanup do
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

      describe 'upgrades', :with_cleanup do
        context 'initial installation' do
          let(:extra_manifest) do
            <<-MANIFEST
              elasticsearch::plugin { '#{plugins[:github][:repository]}#{plugins[:github][:name]}/v#{plugins[:github][:initial]}':
                instances => 'es-01',
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
            'contains the initial plugin version',
            'name' => plugins[:github][:name],
            'version' => plugins[:github][:initial]
          )
        end

        describe 'upgrading' do
          let(:extra_manifest) do
            <<-MANIFEST
              elasticsearch::plugin { '#{plugins[:github][:repository]}#{plugins[:github][:name]}/v#{plugins[:github][:upgraded]}':
                instances => 'es-01',
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
            'contains the upgraded plugin version',
            'name' => plugins[:github][:name],
            'version' => plugins[:github][:upgraded]
          )
        end
      end

      describe 'offline via puppet://', :with_cleanup do
        shell "mkdir -p #{default['distmoduledir']}/another/files"

        scp_to(
          default,
          plugins[:offline][:path],
          "#{default['distmoduledir']}/another/files/plugin.zip"
        )

        let(:extra_manifest) do
          <<-MANIFEST
            elasticsearch::plugin { '#{plugins[:offline][:name]}':
              instances => 'es-01',
              source    => 'puppet:///modules/another/plugin.zip',
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
          'name' => plugins[:offline][:name]
        )
      end

      describe 'via url', :with_cleanup do
        let(:extra_manifest) do
          <<-MANIFEST
            elasticsearch::plugin { '#{plugins[:remote][:name]}':
              instances => 'es-01',
              url       => '#{plugins[:remote][:url]}',
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
          'name' => plugins[:remote][:name]
        )
      end
    end
  end
end
