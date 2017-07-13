module Puppet_X
  module Elastic
    # Attempt to guess at the plugin's final directory name
    def self.plugin_name(original_string)
      # Try both colon (maven) and slash-delimited (github/elastic.co) names
      %w[/ :].each do |delimiter|
        _vendor, plugin, _version = original_string.split(delimiter)
        # If the string successfully split, assume we found the right format
        return plugin.gsub(/(elasticsearch-|es-)/, '') unless plugin.nil?
      end

      # Fallback to the originally passed plugin name
      original_string
    end
  end # of Elastic
end # of Puppet_X
