require 'spec_helper_acceptance'
require 'base64'

describe "elasticsearch shield" do

  let(:single_manifest) do
    <<EOF
class { 'elasticsearch' :
  java_install => true,
  manage_repo  => true,
  repo_version => '1.7',
}

elasticsearch::instance { ['es-01'] :  }

Elasticsearch::Plugin { instances => ['es-01'],  }

elasticsearch::plugin { 'elasticsearch/license/latest' :  }
elasticsearch::plugin { 'elasticsearch/shield/latest' :  }

elasticsearch::shield::user { '#{@user}':
  password => '#{@user_password}',
  roles    => ['admin'],
}
EOF
  end

  describe 'single instance manifest' do
    it 'should apply cleanly' do
      apply_manifest single_manifest, :catch_failures => true
    end

    it 'should be idempotent' do
      expect(apply_manifest(single_manifest, :catch_failures => true).exit_code).to be_zero
    end

    describe "secured REST endpoint" do
      it 'denies unauthorized access' do
        curl_with_retries(
          'anonymous cluster health request',
          default,
          "-s -I http://localhost:9200/_cluster/health " \
            "| grep '401 Unauthorized'", 0)
      end

      it 'permits authorized access' do
        curl_with_retries(
          'elastic user cluster health request',
          default,
          "-s -I -u #{@user}:#{@user_password} "\
          "http://localhost:9200/_cluster/health " \
            "| grep '200 Okay'", 0)
      end
    end
  end

  # Big setup for TLS key and cert generation.
  before :all do
    # Authentication instance variables
    @user = 'elastic'
    @user_password = SecureRandom.hex
    @keystore_password = SecureRandom.hex
    @tls = {}

    # Setup TLS cert placement
    gen_certs(@keystore_password).each do |cert, pem|
      path = "/tmp/#{cert}.pem"
      @tls[cert] = path
      create_remote_file hosts, path, pem
    end
  end
end
