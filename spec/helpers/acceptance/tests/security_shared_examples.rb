require 'json'
require 'spec_utilities'
require 'helpers/acceptance/tests/manifest_shared_examples'

shared_examples 'security plugin manifest' do |instances, credentials|
  let(:extra_manifest) do
    instance_plugins =
      <<-MANIFEST
        Elasticsearch::Plugin { instances => #{instances.keys} }
      MANIFEST

    users = credentials.map do |username, meta|
      <<-USER
        #{meta[:changed] ? "notify { 'password change for #{username}' : } ~>" : ''}
        elasticsearch::user { '#{username}':
          password => '#{meta[:hash] ? meta[:hash] : meta[:plaintext]}',
          roles    => #{meta[:roles].reduce({}) { |a, e| a.merge(e) }.keys},
        }
      USER
    end.join("\n")

    roles = credentials.values.reduce({}) do |sum, user_metadata|
      # Collect all roles across users
      sum.merge user_metadata
    end[:roles].reduce({}) do |all_roles, role|
      all_roles.merge role
    end.reject do |_role, permissions|
      permissions.empty?
    end.map do |role, rights|
      <<-ROLE
        elasticsearch::role { '#{role}':
            privileges => #{rights}
        }
      ROLE
    end.join("\n")

    <<-MANIFEST
      #{security_plugins}

      #{instance_plugins}

      #{users}

      #{roles}

      #{ssl_params}
    MANIFEST
  end

  include_examples(
    'manifest application',
    instances,
    not(credentials.values.map { |p| p[:changed] }.any?)
  )
end

shared_examples 'secured request' do |test_desc, instances, path, http_test, expected, user = nil, pass = nil, tls = false|
  instances.each_value do |i|
    describe port(i['config']['http.port']) do
      it 'open', :with_retries do
        should be_listening
      end
    end

    describe server :container do
      describe http(
        "http#{tls ? 's' : ''}://localhost:#{i['config']['http.port']}#{path}",
        {
          :ssl => { :verify => false }
        }.merge((user and pass) ? { :basic_auth => [user, pass] } : {})
      ) do
        it test_desc, :with_retries do
          expect(http_test.call(response)).to eq(expected)
        end
      end
    end
  end
end

shared_examples 'security acceptance tests' do |default_instances|
  describe 'security plugin operations', :then_purge do
    let(:ssl_params) { '' }

    superuser_role = v[:elasticsearch_major_version] > 2 ? 'superuser' : 'admin'

    let(:manifest_class_parameters) do
      <<-MANIFEST
        restart_on_change => true,
        security_plugin => '#{v[:elasticsearch_major_version] > 2 ? 'x-pack' : 'shield'}',
      MANIFEST
    end

    let(:security_plugins) do
      if v[:elasticsearch_major_version] > 2
        <<-MANIFEST
          elasticsearch::plugin { 'x-pack' :  }
        MANIFEST
      else
        <<-MANIFEST
          elasticsearch::plugin { 'elasticsearch/license/latest' :  }
          elasticsearch::plugin { 'elasticsearch/shield/latest' : }
        MANIFEST
      end
    end

    rand_string = lambda { [*('a'..'z')].sample(8).join }
    user_one = rand_string.call
    user_two = rand_string.call

    context "instance #{default_instances.first.first}" do
      instance = [default_instances.first].to_h

      describe 'user authentication' do
        user_one_pw = rand_string.call
        user_two_pw = rand_string.call
        username_passwords = {
          user_one => { :plaintext => user_one_pw, :roles => [{ superuser_role => [] }] },
          user_two => { :plaintext => user_two_pw, :roles => [{ superuser_role => [] }] }
        }
        username_passwords[user_two][:hash] = bcrypt(username_passwords[user_two][:plaintext])

        include_examples('security plugin manifest', instance, username_passwords)
        include_examples(
          'secured request', 'denies unauthorized access',
          instance, '/_cluster/health',
          lambda { |r| r.status }, 401
        )
        include_examples(
          'secured request', "permits user #{user_one} access",
          instance, '/_cluster/health',
          lambda { |r| r.status }, 200,
          user_one, user_one_pw
        )
        include_examples(
          'secured request', "permits user #{user_two} access",
          instance, '/_cluster/health',
          lambda { |r| r.status }, 200,
          user_two, user_two_pw
        )
      end

      describe 'changing passwords' do
        new_password = rand_string.call
        username_passwords = {
          user_one => {
            :plaintext => new_password,
            :changed => true,
            :roles => [{ superuser_role => [] }]
          }
        }

        include_examples('security plugin manifest', instance, username_passwords)
        include_examples(
          'secured request', 'denies unauthorized access', instance, '/_cluster/health',
          lambda { |r| r.status }, 401
        )
        include_examples(
          'secured request', "permits user #{user_two} access with new password",
          instance, '/_cluster/health',
          lambda { |r| r.status }, 200,
          user_one, new_password
        )
      end

      describe 'roles' do
        password = rand_string.call
        username = rand_string.call
        user = {
          username => {
            :plaintext => password,
            :roles => [{
              rand_string.call => {
                'cluster' => [
                  'cluster:monitor/health'
                ]
              }
            }]
          }
        }

        include_examples('security plugin manifest', instance, user)
        include_examples(
          'secured request', 'denies unauthorized access',
          instance, '/_snapshot',
          lambda { |r| r.status }, 403,
          username, password
        )
        include_examples(
          'secured request', 'permits authorized access',
          instance, '/_cluster/health',
          lambda { |r| r.status }, 200,
          username, password
        )
      end
    end

    describe 'tls', :with_certificates do
      describe 'with one instance' do
        instance_name = default_instances.keys.first
        instance = { instance_name => default_instances[instance_name].merge('ssl' => true) }

        let(:ssl_params) do
          <<-MANIFEST
            Elasticsearch::Instance['es-01'] {
              ca_certificate    => '#{@tls[:ca][:cert][:path]}',
              certificate       => '#{@tls[:clients].first[:cert][:path]}',
              private_key       => '#{@tls[:clients].first[:key][:path]}',
              keystore_password => '#{@keystore_password}',
            }
          MANIFEST
        end

        username = rand_string.call
        password = rand_string.call

        include_examples(
          'security plugin manifest',
          instance,
          username => {
            :plaintext => password,
            :roles => [{ superuser_role => [] }]
          }
        )

        include_examples(
          'secured request', 'permits requests over ssl',
          instance, '/_cluster/health',
          lambda { |r| r.status }, 200,
          username, password, true
        )
      end

      describe 'with two instances' do
        ssl_instances = default_instances.map do |instance, meta|
          new_config = if v[:elasticsearch_major_version] > 2
                         { 'xpack.ssl.verification_mode' => 'none' }
                       else
                         { 'shield.ssl.hostname_verification' => false }
                       end
          [
            instance,
            {
              'config' => meta['config'].merge(new_config).merge(
                'discovery.zen.minimum_master_nodes' => default_instances.keys.size
              ),
              'ssl' => true
            }
          ]
        end.to_h

        let(:ssl_params) do
          @tls[:clients].each_with_index.map do |cert, i|
            format(%(
              Elasticsearch::Instance['es-%02d'] {
                ca_certificate    => '#{@tls[:ca][:cert][:path]}',
                certificate       => '#{cert[:cert][:path]}',
                private_key       => '#{cert[:key][:path]}',
                keystore_password => '#{@keystore_password}',
              }
            ), i + 1)
          end.join("\n")
        end

        username = rand_string.call
        password = rand_string.call

        include_examples(
          'security plugin manifest',
          ssl_instances,
          username => {
            :plaintext => password,
            :roles => [{ superuser_role => [] }]
          }
        )

        include_examples(
          'secured request', 'clusters between two nodes',
          ssl_instances, '/_nodes',
          lambda { |r| JSON.parse(r.body)['nodes'].size }, 2,
          username, password, true
        )
      end
    end
  end
end
