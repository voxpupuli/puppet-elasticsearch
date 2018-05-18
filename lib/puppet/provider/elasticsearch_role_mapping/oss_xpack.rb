require 'puppet/provider/elastic_yaml'

Puppet::Type.type(:elasticsearch_role_mapping).provide(
  :oss_xpack,
  :parent => Puppet::Provider::ElasticYaml,
  :metadata => :mappings
) do
  desc 'Provider for OSS X-Pack role mappings.'

  xpack_config 'role_mapping.yml'
  confine :exists => default_target
end
