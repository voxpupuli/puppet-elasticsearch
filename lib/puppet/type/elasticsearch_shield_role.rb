Puppet::Type.newtype(:elasticsearch_shield_role) do
  desc "Type to model Elasticsearch shield roles."

  ensurable do
    defaultvalues
    defaultto :present
  end

  newparam(:name, :namevar => true) do
    desc 'Role name.'

    validate do |value|
      case value.length
      when 1..30
        unless value =~ /^\w/
          raise ArgumentError, 'Role name must begin with A-Z, a-z, or _.'
        end
      else
        raise ArgumentError,
          'Role name must be from 1 to 30 characters in length.'
      end
    end
  end

  newproperty(:privileges) do
    desc 'Security privileges of the given role.'
  end
end
