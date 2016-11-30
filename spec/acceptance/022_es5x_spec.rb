require 'spec_helper_acceptance'

describe 'elasticsearch 5.x' do
  # Java 8 is only easy to manage on recent distros
  if (fact('osfamily') == 'RedHat' and \
      not (fact('operatingsystem') == 'OracleLinux' and \
       fact('operatingsystemmajrelease') == '6')) or \
      fact('lsbdistcodename') == 'xenial'
    # On earlier versions of CentOS/RedHat 7, manually get JRE 1.8
    if fact('operatingsystemmajrelease') == '6'
      # Otherwise, grab the Oracle JRE 8 package
      java_install = false
      java_snippet = <<-EOS
        package { 'java-1.7.0-openjdk' :
          ensure => absent
        } ->
        java::oracle { 'jre8':
          java_se => 'jre',
        }
      EOS
    else
      # Otherwise the distro should be recent enough to have JRE 1.8
      java_install = true
    end

    describe 'basic installation', :with_cleanup do
      describe 'manifest' do
        pp = <<-EOS
          class { 'elasticsearch':
            config => {
              'node.name' => 'elasticsearch001',
              'cluster.name' => '#{test_settings['cluster_name']}',
              'network.host' => '0.0.0.0',
            },
            manage_repo => true,
            repo_version => '#{test_settings['repo_version5x']}',
            java_install => #{java_install},
            restart_on_change => true,
          }

          elasticsearch::instance { 'es-01':
            config => {
              'node.name' => 'elasticsearch001',
              'http.port' => '#{test_settings['port_a']}'
            }
          }
        EOS
        if not java_install
          pp = java_snippet + "->\n" + pp
        end

        it 'applies cleanly' do
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
        describe http "http://localhost:#{test_settings['port_a']}" do
          it 'runs version 5', :with_retries do
            expect(
              JSON.parse(response.body)['version']['number']
            ).to start_with('5')
          end
        end
      end
    end
  else
    describe 'unsupported' do
      pending 'testing on distribution'
    end
  end
end
