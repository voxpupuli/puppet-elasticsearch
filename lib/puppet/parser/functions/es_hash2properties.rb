# frozen_string_literal: true

# Top-level Puppet functions
module Puppet::Parser::Functions
  newfunction(
    :es_hash2properties,
    type: :rvalue,
    doc: <<-'ENDHEREDOC') do |args|
    Converts a puppet hash to Java properties file string

    For example:

        $hash = {'a' => 'value'}
        es_hash2properties($hash)

    @return String
    ENDHEREDOC

    # Technically we support two arguments but only first is mandatory ...
    raise Puppet::ParseError, "es_hash2properties(): wrong number of arguments (#{args.length}; must be at least 1)" if args.empty?

    input = args[0]

    raise Puppet::ParseError, "es_hash2properties: expected first argument to be an Hash, got #{input.inspect}" unless input.is_a?(Hash)

    options = args[1] if args[1]

    raise Puppet::ParseError, "es_hash2properties: expected second argument to be a Hash, got #{options.inspect}" if options && !(options.is_a? Hash)

    settings = {
      'header' => '# THIS FILE IS MANAGED BY PUPPET',
      'key_val_separator' => ' = ',
      'quote_char' => '',
      'list_separator' => ',',
    }

    settings.merge!(options) if options

    result = []
    key_hashes = input.to_a
    properties = {}
    list_separator = settings['list_separator']
    until key_hashes.empty?
      key_value = key_hashes.pop
      if key_value[1].is_a?(Hash)
        key_hashes += key_value[1].to_a.map { |key, value| ["#{key_value[0]}.#{key}", value] }
      else
        prop_value = if key_value[1].is_a?(Array)
                       key_value[1].join(list_separator)
                     else
                       prop_value = key_value[1]
                     end
        properties[key_value[0]] = prop_value
      end
    end

    key_val_separator = settings['key_val_separator']
    quote_char = settings['quote_char']

    properties.each do |property, value|
      result << "#{property}#{key_val_separator}#{quote_char}#{value}#{quote_char}"
    end

    result.sort! { |x, y| String(x) <=> String(y) }
    result.insert(0, settings['header'])
    result << ''

    return result.join("\n")
  end
end
