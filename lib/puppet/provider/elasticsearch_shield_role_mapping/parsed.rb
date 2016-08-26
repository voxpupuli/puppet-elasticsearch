require 'puppet/provider/elastic_yaml'

Puppet::Type.type(:elasticsearch_shield_role_mapping).provide(
  :parsed,
  :parent => Puppet::Provider::ElasticYaml,
  :metadata => :mappings
) do
  desc "Provider for Shield role mappings."

  shield_config 'role_mapping.yml'
end
