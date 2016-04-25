require 'spec_helper_acceptance'

describe "elasticsearch shield" do

  # Template manifest
  let :base_manifest do <<-EOF
class { 'elasticsearch' :
  java_install => true,
  manage_repo  => true,
  repo_version => '1.7',
}

elasticsearch::plugin { 'elasticsearch/license/latest' :  }
elasticsearch::plugin { 'elasticsearch/shield/latest' :  }
EOF
  end

  describe 'user authentication' do

    describe 'single instance manifest' do

      let :single_manifest do
        base_manifest + <<EOF
elasticsearch::instance { ['es-01'] :  }

Elasticsearch::Plugin { instances => ['es-01'],  }

elasticsearch::shield::user { '#{@user}':
  password => '#{@user_password}',
  roles    => ['admin'],
}
EOF
      end

      it 'should apply cleanly' do
        apply_manifest single_manifest, :catch_failures => true
      end

      it 'should be idempotent' do
        expect(apply_manifest(
          single_manifest, :catch_failures => true
        ).exit_code).to be_zero
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

  describe 'role permission control' do

    describe 'single instance manifest' do

      let :single_manifest do
        base_manifest + <<EOF
elasticsearch::instance { ['es-01'] :  }

Elasticsearch::Plugin { instances => ['es-01'],  }

elasticsearch::shield::role { '#{@role}':
  privileges => {
    'indices' => {
      '#{@role}' => 'create_index'
    }
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
        expect(apply_manifest(
          single_manifest, :catch_failures => true
        ).exit_code).to be_zero
      end
    end

    describe "secured REST endpoint" do
      it 'denies unauthorized access' do
        curl_with_retries(
          'unauthorized elastic user creating an index',
          default,
          "-s -I -u #{@user}:#{@user_password} "\
          "-XPUT http://localhost:9200/#{SecureRandom.hex} " \
            "| grep '403 Forbidden'", 0)
      end

      it 'permits authorized access' do
        curl_with_retries(
          'authorized elastic user creating an index',
          default,
          "-s -I -u #{@user}:#{@user_password} "\
          "-XPUT http://localhost:9200/#{@role} " \
            "| grep '200 OK'", 0)
      end
    end
  end

  describe 'tls' do

    describe 'single instance manifest' do

      let :single_manifest do
        base_manifest + <<EOF
elasticsearch::instance { 'es-01':
  ssl                  => true,
  ca_certificate       => '#{@tls[:ca]}',
  certificate          => '#{@tls[:cert]}',
  private_key          => '#{@tls[:key]}',
  private_key_password => '#{@keystore_password}',
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
        expect(apply_manifest(
          single_manifest, :catch_failures => true
        ).exit_code).to be_zero
      end
    end

    describe "REST endpoint" do
      it 'serves over HTTPS' do
        curl_with_retries(
          'authenticated local https node health',
          default,
          "-s -I -u #{@user}:#{@user_password} "\
            "--cacert #{@tls[:ca]} " \
            "-XGET https://localhost:9200 " \
            "| grep '200 OK'", 0)
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
    @tls = {}

    # Setup TLS cert placement
    gen_certs.each do |cert, pem|
      path = "/tmp/#{cert}.pem"
      @tls[cert] = path
      create_remote_file hosts, path, pem
    end
  end
end
