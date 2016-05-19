module Puppet_X
  module Elastic
    module Hash

      # Upon extension, recurse into the hash to extend all nested
      # hashes with the sorted each_pair method.
      # Note that respond_to? is used here as there were weird
      # problems with .class/.is_a?
      def self.extended(base)
        base.merge! base do |_, ov, nv|
          if ov.respond_to? :each_pair
            ov.extend Puppet_X::Elastic::Hash
          elsif ov.is_a? Array
            ov.map do |elem|
              if elem.respond_to? :each_pair
                elem.extend Puppet_X::Elastic::Hash
              else
                elem
              end
            end
          else
            ov
          end
        end
      end

      # Override each_pair with a method that yields key/values in
      # sorted order.
      def each_pair
        keys.sort.each do |key|
          yield key, self[key]
        end
      end
    end
  end
end
