require 'spec_helper_acceptance'

describe "elasticsearch shield" do

  # Template manifest
  let :base_manifest do <<-EOF
    class { 'elasticsearch' :
      java_install => true,
      manage_repo  => true,
      repo_version => '#{test_settings['repo_version']}',
    }

    elasticsearch::plugin { 'elasticsearch/license/latest' :  }
    elasticsearch::plugin { 'elasticsearch/shield/latest' : }
    EOF
  end

  describe 'user authentication' do

    describe 'single instance manifest' do

      let :single_manifest do
        base_manifest + <<-EOF
          elasticsearch::instance { ['es-01'] :  }

          Elasticsearch::Plugin { instances => ['es-01'],  }

          elasticsearch::shield::user { '#{@user}':
            password => '#{@user_password}',
            roles    => ['admin'],
          }
          elasticsearch::shield::user { '#{@user}pwchange':
            password => '#{@user_password}',
            roles    => ['admin'],
          }
        EOF
      end

      it 'should apply cleanly' do
        apply_manifest single_manifest, :catch_failures => true
      end

      it 'should be idempotent' do
        apply_manifest(
          single_manifest,
          :catch_changes => true
        )
      end
    end

    describe "secured REST endpoint" do
      it 'denies unauthorized access' do
        curl_with_retries(
          'anonymous cluster health request',
          default,
          "-s -I -XGET http://localhost:9200/_cluster/health " \
            "| grep '401 Unauthorized'", 0)
      end

      it 'permits authorized access' do
        curl_with_retries(
          'elastic user cluster health request',
          default,
          "-s -I -XGET -u #{@user}:#{@user_password} "\
          "http://localhost:9200/_cluster/health " \
            "| grep '200 OK'", 0)
      end
    end
  end

  describe 'changing passwords' do
    describe 'password change manifest' do

      let :passwd_manifest do
        base_manifest + <<-EOF
          elasticsearch::instance { ['es-01'] :  }

          Elasticsearch::Plugin { instances => ['es-01'],  }

          notify { 'change password' : } ~>
          elasticsearch::shield::user { '#{@user}pwchange':
            password => '#{@user_password[0..5]}',
            roles    => ['admin'],
          }
        EOF
      end

      it 'should apply cleanly' do
        apply_manifest passwd_manifest, :catch_failures => true
      end
    end

    describe "secured REST endpoint" do
      it 'authorizes changed passwords' do
        curl_with_retries(
          'elastic user cluster health request with new password',
          default,
          "-s -I -XGET -u #{@user}pwchange:#{@user_password[0..5]} "\
          "http://localhost:9200/_cluster/health " \
            "| grep '200 OK'", 0)
      end
    end
  end

  describe 'role permission control' do

    describe 'single instance manifest' do

      let :single_manifest do
        base_manifest + <<-EOF
          elasticsearch::instance { ['es-01'] :  }

          Elasticsearch::Plugin { instances => ['es-01'],  }


          elasticsearch::shield::role { '#{@role}':
            privileges => {
              'cluster' => [
                'cluster:monitor/health',
              ]
            }
          }

          elasticsearch::shield::user { '#{@user}':
            password => '#{@user_password}',
            roles    => ['#{@role}'],
          }
        EOF
      end

      it 'should apply cleanly' do
        apply_manifest single_manifest, :catch_failures => true
      end

      it 'should be idempotent' do
        apply_manifest(
          single_manifest,
          :catch_changes => true
        )
      end
    end

    describe "secured REST endpoint" do
      it 'denies unauthorized access' do
        curl_with_retries(
          'unauthorized elastic user creating an index',
          default,
          "-s -I -XGET -u #{@user}:#{@user_password} "\
          "http://localhost:9200/_cluster/stats " \
            "| grep '403 Forbidden'", 0)
      end

      it 'permits authorized access' do
        curl_with_retries(
          'authorized elastic user creating an index',
          default,
          "-s -I -XGET -u #{@user}:#{@user_password} "\
          "http://localhost:9200/_cluster/health " \
            "| grep '200 OK'", 0)
      end
    end
  end

  describe 'tls' do

    describe 'single instance' do

      describe 'manifest' do

        let :single_manifest do
          base_manifest + <<-EOF
            elasticsearch::instance { 'es-01':
              ssl                  => true,
              ca_certificate       => '#{@tls[:ca][:cert][:path]}',
              certificate          => '#{@tls[:clients].first[:cert][:path]}',
              private_key          => '#{@tls[:clients].first[:key][:path]}',
              keystore_password    => '#{@keystore_password}',
            }

            Elasticsearch::Plugin { instances => ['es-01'],  }

            elasticsearch::shield::user { '#{@user}':
              password => '#{@user_password}',
              roles => ['admin'],
            }
          EOF
        end

        it 'should apply cleanly' do
          apply_manifest single_manifest, :catch_failures => true
        end

        it 'should be idempotent' do
          apply_manifest(
            single_manifest,
            :catch_changes => true
          )
        end
      end

      describe "REST endpoint" do
        it 'serves over HTTPS' do
          curl_with_retries(
            'authenticated local https node health',
            default,
            "-s -I -u #{@user}:#{@user_password} "\
              "--cacert #{@tls[:ca][:cert][:path]} " \
              "-XGET https://localhost:9200 " \
              "| grep '200 OK'", 0)
        end
      end
    end

    describe 'multi-instance' do

      describe 'manifest' do

        let :multi_manifest do
          base_manifest + %Q{
            elasticsearch::shield::user { '#{@user}':
              password => '#{@user_password}',
              roles => ['admin'],
            }
          } + @tls[:clients].each_with_index.map do |cert, i|
            %Q{
              elasticsearch::instance { 'es-%02d':
                ssl                  => true,
                ca_certificate       => '#{@tls[:ca][:cert][:path]}',
                certificate          => '#{cert[:cert][:path]}',
                private_key          => '#{cert[:key][:path]}',
                keystore_password    => '#{@keystore_password}',
                config => {
                  'discovery.zen.minimum_master_nodes' => %s,
                  'shield.ssl.hostname_verification' => false,
                }
              }
            } % [i+1, i+1, @tls[:clients].length]
          end.join("\n") + %Q{
            Elasticsearch::Plugin { instances => %s, }
          } % @tls[:clients].each_with_index.map { |_, i| "es-%02d" % (i+1)}.to_s
        end

        it 'should apply cleanly' do
          apply_manifest multi_manifest, :catch_failures => true
        end

        it 'should be idempotent' do
          apply_manifest(
            multi_manifest,
            :catch_changes => true
          )
        end
      end

      describe "cat nodes" do
        it 'returns TLS-clustered nodes' do
          curl_with_retries(
            'authenticated local https node health',
            default,
            "-s -u #{@user}:#{@user_password} "\
              "--cacert #{@tls[:ca][:cert][:path]} " \
              "-XGET https://localhost:9200/_cat/nodes " \
              "| wc -l | grep '^2$'", 0)
        end
      end
    end
  end

  describe 'module removal' do

    describe 'manifest' do

      let :removal_manifest do
        %Q{
          class { 'elasticsearch' : ensure => absent, }

          Elasticsearch::Instance { ensure => absent, }
          elasticsearch::instance { %s : }
        } % @tls[:clients].each_with_index.map do |_, i|
          "es-%02d" % (i+1)
        end.to_s
      end

      it 'should apply cleanly' do
        apply_manifest removal_manifest, :catch_failures => true
      end
    end
  end


  # Boilerplate for shield setup
  before :all do

    # Authentication instance variables
    @user = 'elastic'
    @user_password = SecureRandom.hex
    @keystore_password = SecureRandom.hex
    @role = [*('a'..'z')].sample(8).join

    # Setup TLS cert placement
    @tls = gen_certs(2, '/tmp')

    create_remote_file hosts, @tls[:ca][:cert][:path], @tls[:ca][:cert][:pem]
    @tls[:clients].each do |node|
      node.each do |type, params|
        create_remote_file hosts, params[:path], params[:pem]
      end
    end
  end
end
