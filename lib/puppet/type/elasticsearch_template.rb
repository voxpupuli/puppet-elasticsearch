require 'puppet/parameter/boolean'

Puppet::Type.newtype(:elasticsearch_template) do
  desc 'Manages Elasticsearch index templates.'

  ensurable do
    defaultvalues
    defaultto :present
  end

  newparam(:name, :namevar => true) do
    desc 'Template name.'
  end

  newproperty(:content) do
    desc 'Structured content of template.'

    validate do |value|
      raise Puppet::Error, 'hash expected' unless value.is_a? Hash
    end

    # This ugly hack is required due to the fact Puppet passes in the
    # puppet-native hash with stringified numerics, which causes the
    # decoded JSON from the Elasticsearch API to be seen as out-of-sync
    # when the parsed template hash is compared against the puppet hash.
    munge do |value|
      deep_to_i = Proc.new do |obj|
        if obj.is_a? String and obj =~ /^[0-9]+$/
          obj.to_i
        elsif obj.is_a? Array
          obj.map { |element| deep_to_i.call element }
        elsif obj.is_a? Hash
          obj.merge(obj) { |key, val| deep_to_i.call val }
        else
          obj
        end
      end

      deep_to_i.call value
    end
  end

  newparam(:host) do
    desc 'Optional host where Elasticsearch is listening.'
    defaultto 'localhost'

    validate do |value|
      unless value.is_a? String
        raise Puppet::Error, 'invalid parameer, expected string'
      end
    end
  end

  newparam(:port) do
    desc 'Port to use for Elasticsearch HTTP API operations.'
    defaultto 9200

    munge do |value|
      if value.is_a? String
        value.to_i
      elsif value.is_a? Fixnum
        value
      else
        raise Puppet::Error, "unknown '#{value}' timeout type '#{value.class}'"
      end
    end
  end

  newparam(:ssl, :boolean => true, :parent => Puppet::Parameter::Boolean) do
    desc 'Whether to communicate with the Elasticsearch API over TLS/SSL.'
    defaultto false
  end

  newparam(
    :ssl_verify,
    :boolean => true,
    :parent => Puppet::Parameter::Boolean
  ) do
    desc 'Whether to verify TLS/SSL certificates.'
    defaultto true
  end

  newparam(:timeout) do
    desc 'HTTP timeout for reading/writing content to Elasticsearch.'
    defaultto 10

    munge do |value|
      if value.is_a? String
        value.to_i
      elsif value.is_a? Fixnum
        value
      else
        raise Puppet::Error, "unknown '#{value}' timeout type '#{value.class}'"
      end
    end

    validate do |value|
      if value.to_s !~ /^\d+$/
        raise Puppet::Error, 'timeout must be a positive integer'
      end
    end
  end

  newparam(:username) do
    desc 'Optional HTTP basic authentication username for Elasticsearch.'
  end

  newparam(:password) do
    desc 'Optional HTTP basic authentication plaintext password for Elasticsearch.'
  end
end
