require 'puppet/provider/elastic_plugin'

Puppet::Type.type(:elasticsearch_plugin).provide(
  :plugin,
  :parent => Puppet::Provider::ElasticPlugin
) do
  desc 'Pre-5.x provider for Elasticsearch bin/plugin command operations.'

  commands :plugin => @parameters[:home_dir] + '/bin/plugin'
  commands :es => @parameters[:home_dir] + '/bin/elasticsearch'
  case Facter.value('osfamily')
  when 'OpenBSD'
    commands :javapathhelper => '/usr/local/bin/javaPathHelper'
  end
end
