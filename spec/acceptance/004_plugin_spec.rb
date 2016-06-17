require 'spec_helper_acceptance'
require 'spec_helper_faraday'
require 'json'

describe 'elasticsearch::plugin' do

  before :all do
    shell "mkdir -p #{default['distmoduledir']}/another/files"

    shell %W{
      ln -s /tmp/elasticsearch-bigdesk.zip
      #{default['distmoduledir']}/another/files/elasticsearch-bigdesk.zip
    }.join(' ')
  end

  context 'official repo', :with_cleanup do
    describe 'manifest' do
      pp = <<-EOS
        class { 'elasticsearch':
          config => {
            'node.name' => 'elasticsearch001',
            'cluster.name' => '#{test_settings['cluster_name']}'
          },
          manage_repo => true,
          repo_version => '#{test_settings['repo_version']}',
          java_install => true
        }

        elasticsearch::instance { 'es-01':
          config => {
            'node.name' => 'elasticsearch001',
            'http.port' => '#{test_settings['port_a']}'
          }
        }

        elasticsearch::plugin { 'mobz/elasticsearch-head':
           module_dir => 'head',
           instances => 'es-01'
        }
      EOS

      it 'applies cleanly ' do
        apply_manifest pp, :catch_failures => true
      end
      it 'is idempotent' do
        apply_manifest pp , :catch_changes  => true
      end
    end

    describe file('/usr/share/elasticsearch/plugins/head/') do
      it { should be_directory }
    end

    describe port(test_settings['port_a']) do
      it 'open', :with_retries do should be_listening end
    end

    describe server :container do
      describe http(
        "http://localhost:#{test_settings['port_a']}/_cluster/stats",
        :faraday_middleware => middleware
      ) do
        it 'reports the plugin as installed', :with_retries do
          plugins = JSON.parse(response.body)['nodes']['plugins'].map do |h|
            h['name']
          end
          expect(plugins).to include('head')
        end
      end
    end
  end

  # Pending
  context 'custom git repo' do
    describe 'manifest'
    describe file('/usr/share/elasticsearch/plugins/head/')
    describe server :container
  end

  if fact('puppetversion') =~ /3\.[2-9]\./
    context 'invalid plugin', :with_cleanup do
      describe 'manifest' do
        pp = <<-EOS
          class { 'elasticsearch':
            config => {
              'node.name' => 'elasticearch001',
              'cluster.name' => '#{test_settings['cluster_name']}'
            },
            manage_repo => true,
            repo_version => '#{test_settings['repo_version']}',
            java_install => true
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

        it 'fails to apply cleanly' do
          apply_manifest pp, :expect_failures => true
        end
      end
    end
  else
    # The exit codes have changes since Puppet 3.2x
    # Since beaker expectations are based on the most recent puppet code
    # all runs on previous versions fails.
  end

  describe 'running ES under user "root"', :with_cleanup do
    describe 'manifest' do
      pp = <<-EOS
        class { 'elasticsearch':
          config => {
            'node.name' => 'elasticsearch001',
            'cluster.name' => '#{test_settings['cluster_name']}'
          },
          manage_repo => true,
          repo_version => '#{test_settings['repo_version']}',
          java_install => true,
          elasticsearch_user => 'root',
          elasticsearch_group => 'root'
        }

        elasticsearch::instance { 'es-01':
          config => {
            'node.name' => 'elasticsearch001',
            'http.port' => '#{test_settings['port_a']}'
          }
        }

        elasticsearch::plugin { 'lmenezes/elasticsearch-kopf':
          module_dir => 'kopf',
          instances => 'es-01'
        }
      EOS

      it 'applies cleanly ' do
        apply_manifest pp, :catch_failures => true
      end
      it 'is idempotent' do
        apply_manifest pp , :catch_changes  => true
      end
    end

    describe file('/usr/share/elasticsearch/plugins/kopf/') do
      it { should be_directory }
    end

    describe port(test_settings['port_a']) do
      it 'open', :with_retries do should be_listening end
    end

    describe server :container do
      describe http(
        "http://localhost:#{test_settings['port_a']}/_cluster/stats",
        :faraday_middleware => middleware
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

  describe 'upgrading', :with_cleanup do
    describe 'initial installation' do
      describe 'first manifest' do
        pp = <<-EOS
          class { 'elasticsearch':
            config => {
              'node.name' => 'elasticsearch001',
              'cluster.name' => '#{test_settings['cluster_name']}'
            },
            manage_repo => true,
            repo_version => '#{test_settings['repo_version']}',
            java_install => true,
            elasticsearch_user => 'root',
            elasticsearch_group => 'root'
          }

          elasticsearch::instance { 'es-01':
            config => {
              'node.name' => 'elasticsearch001',
              'http.port' => '#{test_settings['port_a']}'
            }
          }

          elasticsearch::plugin {'elasticsearch/elasticsearch-cloud-aws/2.1.1':
            module_dir => 'cloud-aws',
            instances => 'es-01'
          }
        EOS

        it 'applies cleanly ' do
          apply_manifest pp, :catch_failures => true
        end
        it 'is idempotent' do
          apply_manifest pp , :catch_changes  => true
        end
      end

      describe file('/usr/share/elasticsearch/plugins/cloud-aws/') do
        it { should be_directory }
      end

      describe port(test_settings['port_a']) do
        it 'open', :with_retries do should be_listening end
      end

      describe server :container do
        describe http(
          "http://localhost:#{test_settings['port_a']}/_cluster/stats",
          :faraday_middleware => middleware
        ) do
          it 'reports the plugin as installed', :with_retries do
            plugin = JSON.parse(response.body)['nodes']['plugins'].find do |h|
              h['name'] == 'cloud-aws'
            end
            expect(plugin).to include('name' => 'cloud-aws')
            expect(plugin).to include('version' => '2.1.1')
          end
        end
      end
    end

    describe 'upgrading' do
      describe 'upgrade manifest' do
        pp = <<-EOS
          class { 'elasticsearch':
            config => {
              'node.name' => 'elasticsearch001',
              'cluster.name' => '#{test_settings['cluster_name']}'
            },
            manage_repo => true,
            repo_version => '#{test_settings['repo_version']}',
            java_install => true,
            elasticsearch_user => 'root',
            elasticsearch_group => 'root'
          }

          elasticsearch::instance { 'es-01':
            config => {
              'node.name' => 'elasticsearch001',
              'http.port' => '#{test_settings['port_a']}'
            }
          }

          elasticsearch::plugin { 'elasticsearch/elasticsearch-cloud-aws/2.2.0':
            module_dir => 'cloud-aws',
            instances => 'es-01'
          }
        EOS

        it 'applies cleanly ' do
          apply_manifest pp, :catch_failures => true
        end
        it 'is idempotent' do
          apply_manifest pp , :catch_changes  => true
        end
      end

      describe port(test_settings['port_a']) do
        it 'open', :with_retries do should be_listening end
      end

      describe server :container do
        describe http(
          "http://localhost:#{test_settings['port_a']}/_cluster/stats",
          :faraday_middleware => middleware
        ) do
          it 'reports the upgraded plugin version', :with_retries do
            plugin = JSON.parse(response.body)['nodes']['plugins'].find do |h|
              h['name'] == 'cloud-aws'
            end
            expect(plugin).to include('version' => '2.2.0')
          end
        end
      end
    end
  end

  describe 'offline installation', :with_cleanup do
    describe 'manifest' do
      pp = <<-EOS
        class { 'elasticsearch':
          config => {
            'node.name' => 'elasticsearch001',
            'cluster.name' => '#{test_settings['cluster_name']}'
          },
          manage_repo => true,
          repo_version => '#{test_settings['repo_version']}',
          java_install => true,
          elasticsearch_user => 'root',
          elasticsearch_group => 'root'
        }

        elasticsearch::instance { 'es-01':
          config => {
            'node.name' => 'elasticsearch001',
            'http.port' => '#{test_settings['port_a']}'
          }
        }

        elasticsearch::plugin { 'bigdesk':
          source => 'puppet:///modules/another/elasticsearch-bigdesk.zip',
          instances => 'es-01'
        }
      EOS

      it 'applies cleanly ' do
        apply_manifest pp, :catch_failures => true
      end
      it 'is idempotent' do
        apply_manifest pp , :catch_changes  => true
      end
    end

    describe port(test_settings['port_a']) do
      it 'open', :with_retries do should be_listening end
    end

    describe server :container do
      describe http(
        "http://localhost:#{test_settings['port_a']}/_cluster/stats",
        :faraday_middleware => middleware
      ) do
        it 'reports the plugin as installed', :with_retries do
          plugins = JSON.parse(response.body)['nodes']['plugins']
          expect(plugins.first).to include('name' => 'bigdesk')
        end
      end
    end
  end

  describe 'installation via url', :with_cleanup do
    describe 'manifest' do
      pp = <<-EOS
        class { 'elasticsearch':
          config => {
            'node.name' => 'elasticsearch001',
            'cluster.name' => '#{test_settings['cluster_name']}'
          },
          manage_repo => true,
          repo_version => '#{test_settings['repo_version']}',
          java_install => true
        }

        elasticsearch::instance { 'es-01':
          config => {
            'node.name' => 'elasticsearch001',
            'http.port' => '#{test_settings['port_a']}'
          }
        }

        elasticsearch::plugin { 'hq':
          url => 'https://github.com/royrusso/elasticsearch-HQ/archive/v2.0.3.zip',
          instances => 'es-01'
        }
      EOS

      it 'applies cleanly ' do
        apply_manifest pp, :catch_failures => true
      end
      it 'is idempotent' do
        apply_manifest pp , :catch_changes  => true
      end
    end

    describe port(test_settings['port_a']) do
      it 'open', :with_retries do should be_listening end
    end

    describe server :container do
      describe http(
        "http://localhost:#{test_settings['port_a']}/_cluster/stats",
        :faraday_middleware => middleware
      ) do
        it 'reports the plugin as installed', :with_retries do
          plugins = JSON.parse(response.body)['nodes']['plugins'].map do |h|
            h['name']
          end
          expect(plugins).to include('hq')
        end
      end
    end
  end
end
