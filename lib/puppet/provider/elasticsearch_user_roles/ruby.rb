# frozen_string_literal: true

require 'puppet/provider/elastic_user_roles'

Puppet::Type.type(:elasticsearch_user_roles).provide(
  :ruby,
  parent: Puppet::Provider::ElasticUserRoles
) do
  desc 'Provider for X-Pack user roles (parsed file.)'

  xpack_config 'users_roles'
end
