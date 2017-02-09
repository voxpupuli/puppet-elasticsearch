require 'spec_helper_acceptance'
require 'json'

# rubocop:disable Metrics/BlockLength
describe 'Integration testing' do
  before :all do
    shell "mkdir -p #{default['distmoduledir']}/another/files"

    create_remote_file default,
                       "#{default['distmoduledir']}/another/files/good.json",
                       JSON.dump(test_settings['template'])

    create_remote_file default,
                       "#{default['distmoduledir']}/another/files/bad.json",
                       JSON.dump(test_settings['template'])[0..-5]
  end

  describe 'Setup Elasticsearch', :main => true do
    it 'should run successfully' do
      pp = <<-EOS
        class { 'elasticsearch':
          config => {
            'cluster.name' => '#{test_settings['cluster_name']}',
            'network.host' => '0.0.0.0',
          },
          java_install => true,
          package_url => '#{test_settings['snapshot_package']}'
        }

        elasticsearch::instance { 'es-01':
          config => {
            'node.name' => 'elasticsearch001',
            'http.port' => '#{test_settings['port_a']}'
          }
        }
      EOS

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end

    describe service(test_settings['service_name_a']) do
      it { should be_enabled }
      it { should be_running }
    end

    describe package(test_settings['package_name']) do
      it { should be_installed }
    end

    describe file(test_settings['pid_a']) do
      it { should be_file }
      its(:content) { should match(/[0-9]+/) }
    end

    describe server :container do
      describe http(
        "http://localhost:#{test_settings['port_a']}"
      ) do
        describe 'instance a' do
          it 'serves requests', :with_retries do
            expect(response.status).to eq(200)
          end
        end
      end
    end

    describe file('/etc/elasticsearch/es-01/elasticsearch.yml') do
      it { should be_file }
      it { should contain 'name: elasticsearch001' }
    end

    describe file('/usr/share/elasticsearch/templates_import') do
      it { should be_directory }
    end
  end

  describe 'Template tests', :template => true do
    describe 'Insert a template with valid json content' do
      it 'should run successfully' do
        pp = <<-EOS
          class { 'elasticsearch':
            config => {
              'cluster.name' => '#{test_settings['cluster_name']}',
              'network.host' => '0.0.0.0',
            },
            java_install => true,
            package_url => '#{test_settings['snapshot_package']}'
          }

          elasticsearch::instance { 'es-01':
            config => {
              'node.name' => 'elasticsearch001',
              'http.port' => '#{test_settings['port_a']}'
            }
          }

          elasticsearch::template { 'foo':
            ensure => 'present',
            source => 'puppet:///modules/another/good.json'
          }
        EOS

        # Run it twice and test for idempotency
        apply_manifest(pp, :catch_failures => true)
        expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
      end

      describe port(test_settings['port_a']) do
        it 'open', :with_retries do
          should be_listening
        end
      end

      describe server :container do
        describe http(
          "http://localhost:#{test_settings['port_a']}/_template/foo",
          :params => { 'flat_settings' => 'false' }
        ) do
          it 'returns the installed template', :with_retries do
            expect(JSON.parse(response.body)['foo'])
              .to include(test_settings['template'])
          end
        end
      end
    end

    describe 'Insert a template with bad json content' do
      it 'run should fail' do
        pp = <<-EOS
          class { 'elasticsearch':
            config => {
              'cluster.name' => '#{test_settings['cluster_name']}',
              'network.host' => '0.0.0.0',
            },
            java_install => true,
            package_url => '#{test_settings['snapshot_package']}'
          }

          elasticsearch::instance { 'es-01':
            config => {
              'node.name' => 'elasticsearch001',
              'http.port' => '#{test_settings['port_a']}'
            }
          }

          elasticsearch::template { 'foo':
            ensure => 'present',
            source => 'puppet:///modules/another/bad.json'
          }
        EOS

        apply_manifest pp, :expect_failures => true
      end
    end
  end

  describe 'Plugin tests', :plugin => true do
    describe 'Install a plugin from official repository' do
      it 'should run successfully' do
        pp = <<-EOS
          class { 'elasticsearch':
            config => {
              'cluster.name' => '#{test_settings['cluster_name']}',
              'network.host' => '0.0.0.0',
            },
            java_install => true,
            package_url => '#{test_settings['snapshot_package']}',
            restart_on_change => true,
          }

          elasticsearch::instance { 'es-01':
            config => {
              'node.name' => 'elasticsearch001',
              'http.port' => '#{test_settings['port_a']}'
            }
          }

          elasticsearch::plugin { 'lmenezes/elasticsearch-kopf':
            instances => 'es-01'
          }
        EOS

        # Run it twice and test for idempotency
        apply_manifest(pp, :catch_failures => true)
        expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
      end

      describe service(test_settings['service_name_a']) do
        it { should be_enabled }
        it { should be_running }
      end

      describe package(test_settings['package_name']) do
        it { should be_installed }
      end

      describe file(test_settings['pid_a']) do
        it { should be_file }
        its(:content) { should match(/[0-9]+/) }
      end

      describe file('/usr/share/elasticsearch/plugins/kopf/') do
        it { should be_directory }
      end

      describe port(test_settings['port_a']) do
        it 'open', :with_retries do
          should be_listening
        end
      end

      describe server :container do
        describe http(
          "http://localhost:#{test_settings['port_a']}/_cluster/stats"
        ) do
          it 'reports the plugin as installed', :with_retries do
            plugins = JSON.parse(response.body)['nodes']['plugins'].map do |h|
              h['name']
            end
            expect(plugins).to include('kopf')
          end
        end
      end
    end

    describe 'Install a non existing plugin' do
      it 'should fail plugin installation' do
        pp = <<-EOS
          class { 'elasticsearch':
            config => {
              'cluster.name' => '#{test_settings['cluster_name']}',
              'network.host' => '0.0.0.0',
            },
            java_install => true,
            package_url => '#{test_settings['snapshot_package']}'
          }

          elasticsearch::instance { 'es-01':
            config => {
              'node.name' => 'elasticsearch001',
              'http.port' => '#{test_settings['port_a']}'
            }
          }

          elasticsearch::plugin { 'elasticsearch/non-existing':
            module_dir => 'non-existing',
            instances => 'es-01'
          }
        EOS

        apply_manifest pp, :expect_failures => true
      end
    end
  end
end
