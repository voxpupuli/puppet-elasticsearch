# frozen_string_literal: true

require 'json'
require 'spec_utilities'
require 'helpers/acceptance/tests/manifest_shared_examples'

shared_examples 'security plugin manifest' do |credentials|
  let(:extra_manifest) do
    users = credentials.map do |username, meta|
      <<-USER
        #{meta[:changed] ? "notify { 'password change for #{username}' : } ~>" : ''}
        elasticsearch::user { '#{username}':
          password => '#{meta[:hash] || meta[:plaintext]}',
          roles    => #{meta[:roles].reduce({}) { |acc, elem| acc.merge(elem) }.keys},
        }
      USER
    end.join("\n")

    roles = credentials.values.reduce({}) do |sum, user_metadata|
      # Collect all roles across users
      sum.merge user_metadata
    end[:roles]
    roles = roles.reduce({}) do |all_roles, role|
      all_roles.merge role
    end
    roles = roles.reject do |_role, permissions|
      permissions.empty?
    end
    roles = roles.map do |role, rights|
      <<-ROLE
        elasticsearch::role { '#{role}':
            privileges => #{rights}
        }
      ROLE
    end
    roles = roles.join("\n")

    <<-MANIFEST
      #{users}

      #{roles}
    MANIFEST
  end

  include_examples(
    'manifest application',
    credentials.values.map { |p| p[:changed] }.none?
  )
end

shared_examples 'secured request' do |test_desc, es_config, path, http_test, expected, user = nil, pass = nil|
  es_port = es_config['http.port']
  describe port(es_port) do
    it 'open', :with_retries do
      expect(subject).to be_listening
    end
  end

  describe "https://localhost:#{es_port}#{path}" do
    subject { shell("curl -k -u #{user}:#{pass} https://localhost:#{es_port}#{path}") }

    it test_desc, :with_retries do
      expect(http_test.call(subject.stdout)).to eq(expected)
    end
  end
end

shared_examples 'security acceptance tests' do |es_config|
  describe 'security plugin operations', if: vault_available?, then_purge: true, with_license: true, with_certificates: true do
    rand_string = -> { [*('a'..'z')].sample(8).join }

    admin_user = rand_string.call
    admin_password = rand_string.call
    admin = { admin_user => { plaintext: admin_password, roles: [{ 'superuser' => [] }] } }

    let(:manifest_class_parameters) do
      <<-MANIFEST
        api_basic_auth_password => '#{admin_password}',
        api_basic_auth_username => '#{admin_user}',
        api_ca_file             => '#{tls[:ca][:cert][:path]}',
        api_protocol            => 'https',
        ca_certificate          => '#{tls[:ca][:cert][:path]}',
        certificate             => '#{tls[:clients].first[:cert][:path]}',
        keystore_password       => '#{keystore_password}',
        license                 => file('#{v[:elasticsearch_license_path]}'),
        private_key             => '#{tls[:clients].first[:key][:path]}',
        restart_on_change       => true,
        ssl                     => true,
        validate_tls            => true,
      MANIFEST
    end

    describe 'over tls' do
      user_one = rand_string.call
      user_two = rand_string.call
      user_one_pw = rand_string.call
      user_two_pw = rand_string.call

      describe 'user authentication' do
        username_passwords = {
          user_one => { plaintext: user_one_pw, roles: [{ 'superuser' => [] }] },
          user_two => { plaintext: user_two_pw, roles: [{ 'superuser' => [] }] }
        }.merge(admin)
        username_passwords[user_two][:hash] = bcrypt(username_passwords[user_two][:plaintext])

        include_examples('security plugin manifest', username_passwords)
        include_examples(
          'secured request', 'denies unauthorized access',
          es_config, '/_cluster/health',
          ->(r) { r.status }, 401
        )
        include_examples(
          'secured request', "permits user #{user_one} access",
          es_config, '/_cluster/health',
          ->(r) { r.status }, 200,
          user_one, user_one_pw
        )
        include_examples(
          'secured request', "permits user #{user_two} access",
          es_config, '/_cluster/health',
          ->(r) { r.status }, 200,
          user_two, user_two_pw
        )
      end

      describe 'changing passwords' do
        new_password = rand_string.call
        username_passwords = {
          user_one => {
            plaintext: new_password,
            changed: true,
            roles: [{ 'superuser' => [] }]
          }
        }

        include_examples('security plugin manifest', username_passwords)
        include_examples(
          'secured request', 'denies unauthorized access', es_config, '/_cluster/health',
          ->(r) { r.status }, 401
        )
        include_examples(
          'secured request', "permits user #{user_two} access with new password",
          es_config, '/_cluster/health',
          ->(r) { r.status }, 200,
          user_one, new_password
        )
      end

      describe 'roles' do
        password = rand_string.call
        username = rand_string.call
        user = {
          username => {
            plaintext: password,
            roles: [{
              rand_string.call => {
                'cluster' => [
                  'cluster:monitor/health'
                ]
              }
            }]
          }
        }

        include_examples('security plugin manifest', user)
        include_examples(
          'secured request', 'denies unauthorized access',
          es_config, '/_snapshot',
          ->(r) { r.status }, 403,
          username, password
        )
        include_examples(
          'secured request', 'permits authorized access',
          es_config, '/_cluster/health',
          ->(r) { r.status }, 200,
          username, password
        )
      end
    end
  end
end
