require 'puppet/provider/parsedfile'

class Puppet::Provider::ElasticParsedFile < Puppet::Provider::ParsedFile
  def self.shield_config(val)
    @default_target ||= "/etc/elasticsearch/shield/#{val}"
  end

  def self.xpack_config(val)
    @default_target ||= "/etc/elasticsearch/x-pack/#{val}"
  end
end
