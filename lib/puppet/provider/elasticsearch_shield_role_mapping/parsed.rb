require 'puppet/provider/elastic_yaml'

mappings = @parameters[:home_dir] + '/shield/role_mapping.yml'

Puppet::Type.type(:elasticsearch_shield_role_mapping).provide(
  :parsed,
  :parent => Puppet::Provider::ElasticYaml,
  :default_target => mappings,
  :metadata => :mappings
) do
  desc "Provider for Shield role mappings."
end
