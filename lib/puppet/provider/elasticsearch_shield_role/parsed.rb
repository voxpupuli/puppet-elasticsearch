require 'puppet/provider/elastic_yaml'

roles = @parameters[:home_dir] + '/shield/roles.yml'

Puppet::Type.type(:elasticsearch_shield_role).provide(
  :parsed,
  :parent => Puppet::Provider::ElasticYaml,
  :default_target => roles,
  :metadata => :privileges
) do
  desc "Provider for Shield role resources."
end
