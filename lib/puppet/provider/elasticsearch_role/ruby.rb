# frozen_string_literal: true

require 'puppet/provider/elastic_yaml'

Puppet::Type.type(:elasticsearch_role).provide(
  :ruby,
  parent: Puppet::Provider::ElasticYaml,
  metadata: :privileges
) do
  desc 'Provider for X-Pack role resources.'

  xpack_config 'roles.yml'
end
