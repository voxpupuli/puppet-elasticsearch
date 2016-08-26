require 'puppet/provider/elastic_yaml'

Puppet::Type.type(:elasticsearch_shield_role).provide(
  :parsed,
  :parent => Puppet::Provider::ElasticYaml,
  :metadata => :privileges
) do
  desc "Provider for Shield role resources."

  shield_config 'roles.yml'
end
