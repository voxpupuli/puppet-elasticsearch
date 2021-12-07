# frozen_string_literal: true

require File.join(File.dirname(__FILE__), '..', '..', '..', 'puppet/provider/elastic_user_command')

Puppet::Type.type(:elasticsearch_user).provide(
  :ruby,
  parent: Puppet::Provider::ElasticUserCommand
) do
  desc 'Provider for X-Pack user resources.'

  has_feature :manages_plaintext_passwords

  mk_resource_methods

  commands users_cli: "#{homedir}/bin/elasticsearch-users"
  commands es: "#{homedir}/bin/elasticsearch"
end
