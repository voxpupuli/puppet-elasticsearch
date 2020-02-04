require File.join(File.dirname(__FILE__), '..', '..', '..', 'puppet/provider/elastic_user_command')

Puppet::Type.type(:elasticsearch_user).provide(
  :elasticsearch_users,
  :parent => Puppet::Provider::ElasticUserCommand
) do
  desc 'Provider for OSS X-Pack user resources.'

  has_feature :manages_plaintext_passwords

  mk_resource_methods

  commands :users_cli => "#{homedir}/bin/elasticsearch-users"
  commands :es => "#{homedir}/bin/elasticsearch"
end
