# frozen_string_literal: true

require 'puppet/provider/parsedfile'

# Parent class for Elasticsearch-based providers that need to access
# specific configuration directories.
class Puppet::Provider::ElasticParsedFile < Puppet::Provider::ParsedFile
  # Find/set an x-pack configuration file.
  #
  # @return String
  def self.xpack_config(val)
    self.default_target ||= "/etc/elasticsearch/#{val}"
  end
end
