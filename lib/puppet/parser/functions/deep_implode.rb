module Puppet::Parser::Functions
  newfunction(
    :deep_implode,
    :type => :rvalue,
    :doc => <<-'ENDHEREDOC') do |args|
    Recursively flattens all keys of a hash into a dot-notated
    hash, deeply merging duplicate key values by natively combining
    them and returns the resulting hash.

    That is confusing, look at the examples for more clarity.

    For example:

        $hash = {'top' => {'sub' => [1]}, 'top.sub' => [2] }
        $flattened_hash = deep_implode($hash)
        # The resulting hash is equivalent to:
        # { 'top.sub' => [1, 2] }

    When the function encounters array or hash values, they are
    concatenated or merged, respectively.
    When duplace paths for a key are generated, the function will prefer
    to retain keys with the longest root key.
    ENDHEREDOC

    if args.length != 1
      raise Puppet::ParseError, ("deep_implode(): wrong number of arguments (#{args.length}; must be 1)")
    end

    arg = args[0]

    unless arg.is_a? Hash
      raise Puppet::ParseError, "deep_implode: unexpected argument type, only expects hashes"
    end

    return {} if arg.empty?

    implode = Proc.new do |path, ret, hash|
      hash.sort_by{|k,v| k.length}.reverse.each do |key, value|
        new_path = path + [key]
        if value.is_a? Hash
          implode.call(new_path, ret, value)
        else
          new_key = new_path.join('.')
          if value.is_a? Array \
              and ret.has_key? new_key \
              and ret[new_key].is_a? Array
              ret[new_key] += value
          else
            ret[new_key] ||= value
          end
        end
      end
    end

    result = Hash.new
    implode.call([], result, arg)
    result
  end
end
