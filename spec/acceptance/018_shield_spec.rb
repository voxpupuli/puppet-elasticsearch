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

    describe server(:container) do
      describe http "http://localhost:9200/_cluster/health" do
        it 'denies unauthorized access' do
          expect(response.status).to eq(401)
        end
      end

      describe http(
        "http://localhost:9200/_cluster/health",
        basic_auth: [@user, @user_password],
      ) do
        it 'permits authorized access' do
          expect(response.status).to eq(200)
        end
      end
    end
    # it 'denies unauthorized access' do
    #   curl_with_retries(
    #     'anonymous cluster health request',
    #     default,
    #     "https://#{default[:name]}:9200/_cluster/health " \
    #       "| grep head", 0)
    #   expect(response.status).to eq(401)
    # end
    #
    # it 'permits authorized access' do
    #   expect(response.status).to eq(200)
    # end
  end

  # Big setup for TLS key and cert generation.
  before :all do
    @user = 'elastic'
    @user_password = SecureRandom.hex
    @keystore_password = SecureRandom.hex
    @password_file = '/tmp/key_password'
    @auth = "Basic "
    @auth << Base64.encode64("#{@user}:#{@user_password}").strip
    @tls = {}

    # Set up CA test files
    #
    # TODO remove once debugging key no longer needed
    create_remote_file hosts, @password_file, @keystore_password

    gen_certs(@keystore_password).each do |cert, pem|
      path = "/tmp/#{cert}.pem"
      @tls[cert] = path
      create_remote_file hosts, path, pem
    end
  end
end
