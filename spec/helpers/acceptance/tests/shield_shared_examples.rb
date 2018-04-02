require 'bcrypt'
require 'json'
require 'helpers/acceptance/tests/manifest_shared_examples'

shared_examples 'shield authentication' do |instances, credentials|
  let(:extra_manifest) do
    users = credentials.map do |username, password|
      <<-USER
        #{password[:changed] ? "notify { 'password change for #{username}' : } ~>" : ''}
        elasticsearch::user { '#{username}':
          password => '#{password[:hash] ? password[:hash] : password[:plaintext]}',
          roles    => ['admin'],
        }
      USER
    end.join("\n")

    <<-MANIFEST
      #{security_plugins}

      #{users}
    MANIFEST
  end

  include_examples(
    'manifest application',
    instances,
    not(credentials.values.map { |p| p[:changed] }.any?)
  )

  include_examples 'authenticated requests', instances, credentials
end

shared_examples 'authenticated requests' do |instances, credentials|
  instances.each_value do |config|
    describe port(config['http.port']) do
      it 'open', :with_retries do
        should be_listening
      end
    end

    describe server :container do
      describe http(
        "http://localhost:#{config['http.port']}/_cluster/health"
      ) do
        it 'denies unauthorized access', :with_retries do
          expect(response.status).to eq(401)
        end
      end

      credentials.each_pair do |username, password|
        describe http(
          "http://localhost:#{config['http.port']}/_cluster/health",
          :basic_auth => [username, password[:plaintext]]
        ) do
          it 'permits authorized access', :with_retries do
            expect(response.status).to eq(200)
          end
        end
      end
    end
  end
end

shared_examples 'shield acceptance tests' do
  describe 'shield', :with_certificates, :then_purge do
    let(:manifest_class_parameters) do
      <<-MANIFEST
        restart_on_change => true,
        security_plugin => 'shield',
      MANIFEST
    end

    let(:security_plugins) do
      <<-MANIFEST
        Elasticsearch::Plugin { instances => ['es-01'] }
        elasticsearch::plugin { 'elasticsearch/license/latest' :  }
        elasticsearch::plugin { 'elasticsearch/shield/latest' : }
      MANIFEST
    end

    rand_string = lambda { [*('a'..'z')].sample(8).join }
    user_one = rand_string.call
    user_two = rand_string.call

    describe 'user authentication' do
      username_passwords = {
        user_one => { :plaintext => rand_string.call },
        user_two => { :plaintext => rand_string.call }
      }
      username_passwords[user_two][:hash] = BCrypt::Password.create(username_passwords[user_two][:plaintext])

      include_examples(
        'shield authentication',
        { 'es-01' => { 'http.port' => 9200, 'node.name' => 'es-01' } },
        username_passwords
      )
    end

    describe 'changing passwords' do
      username_passwords = {
        user_one => { :plaintext => rand_string.call, :changed => true }
      }

      include_examples(
        'shield authentication',
        { 'es-01' => { 'http.port' => 9200, 'node.name' => 'es-01' } },
        username_passwords
      )
    end
  end
end
