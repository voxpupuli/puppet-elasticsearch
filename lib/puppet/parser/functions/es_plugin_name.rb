$LOAD_PATH.unshift(File.join(File.dirname(__FILE__),"..","..",".."))

require 'puppet_x/elastic/plugin_name'

module Puppet::Parser::Functions
  newfunction(
    :es_plugin_name,
    :type => :rvalue,
    :doc => <<-'ENDHEREDOC') do |args|
    Given a string, return the best guess at what the directory name
    will be for the given plugin. Any arguments past the first will
    be fallbacks (using the same logic) should the first fail.

    For example, all the following return values are "plug":

        es_plugin_name('plug')
        es_plugin_name('foo/es-plug/1.3.2')
    ENDHEREDOC

    if args.length < 1
      raise Puppet::ParseError,
        'wrong number of arguments, at least one value required'
    end

    args.each do |arg|
      next unless arg.is_a? String
      next if arg.empty?
      return Puppet_X::Elastic::plugin_name arg
    end

    raise Puppet::Error,
      'could not determine plugin name'
  end
end
