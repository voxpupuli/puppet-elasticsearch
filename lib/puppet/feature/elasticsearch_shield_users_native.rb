# frozen_string_literal: true

require 'puppet/util/feature'
require 'puppet/util/package'

shield_plugin_dir = '/usr/share/elasticsearch/plugins/shield'

Puppet.features.add(:elasticsearch_shield_users_native) do
  return false unless File.exist?(shield_plugin_dir)

  jars = Dir["#{shield_plugin_dir}/*.jar"]
  jar_parts = jars.map do |file|
    File.basename(file, '.jar').split('-')
  end
  shield_components = jar_parts.select do |parts|
    parts.include? 'shield'
  end
  shield_components.any? do |parts|
    parts.last =~ %r{^[\d.]+$} &&
      Puppet::Util::Package.versioncmp(parts.last, '2.3') >= 0
  end
end
