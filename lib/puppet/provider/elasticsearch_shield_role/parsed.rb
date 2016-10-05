require 'puppet/provider/elastic_yaml'

Puppet::Type.type(:elasticsearch_shield_role).provide(
  :parsed,
  :parent => Puppet::Provider::ElasticYaml,
  :metadata => :privileges
) do
  desc "Provider for Shield role resources."
  def default_target
    @default_target ||= resource[:home_dir] + '/shield/roles.yml'
  end
end
