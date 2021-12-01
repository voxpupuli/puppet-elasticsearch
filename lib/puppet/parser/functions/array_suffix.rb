# frozen_string_literal: true

# Top-level Puppet functions
module Puppet::Parser::Functions
  newfunction(
    :array_suffix,
    type: :rvalue,
    doc: <<~EOS
      This function applies a suffix to all elements in an array.

      *Examples:*

          array_suffix(['a','b','c'], 'p')

      Will return: ['ap','bp','cp']

      @return Array
    EOS
  ) do |arguments|
    # Technically we support two arguments but only first is mandatory ...
    if arguments.empty?
      raise(Puppet::ParseError, 'array_suffix(): Wrong number of arguments ' \
                                "given (#{arguments.size} for 1)")
    end

    array = arguments[0]

    raise Puppet::ParseError, "array_suffix(): expected first argument to be an Array, got #{array.inspect}" unless array.is_a?(Array)

    suffix = arguments[1] if arguments[1]

    raise Puppet::ParseError, "array_suffix(): expected second argument to be a String, got #{suffix.inspect}" if suffix && !(suffix.is_a? String)

    # Turn everything into string same as join would do ...
    result = array.map do |i|
      i = i.to_s
      suffix ? i + suffix : i
    end

    return result
  end
end

# vim: set ts=2 sw=2 et :
