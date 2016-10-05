require 'puppet/provider/elastic_yaml'

Puppet::Type.type(:elasticsearch_shield_role_mapping).provide(
  :parsed,
  :parent => Puppet::Provider::ElasticYaml,
) do
  desc "Provider for Shield role mappings."
  def default_target
    @default_target ||= resource[:home_dir] + '/shield/role_mapping.yml'
  end
  def metadata
    @metadata ||= resource[:home_dir] + '/shield/role_mapping.yml'
  end
  
end
