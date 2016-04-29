Puppet::Type.newtype(:elasticsearch_shield_user) do
  desc "Type to model Elasticsearch shield users."

  ensurable do
    defaultvalues
    defaultto :present
  end

  newparam(:username, :namevar => true) do
    desc 'User name.'
  end

  newparam(:password) do
    desc 'Plaintext password for user.'

    validate do |value|
      if value.length < 6
        raise ArgumentError, 'Password must be at least 6 characters long'
      end
    end

    def is_to_s currentvalue
      return '[old password hash redacted]'
    end
    def should_to_s newvalue
      return '[new password hash redacted]'
    end
  end

  newproperty(:roles, :array_matching => :all) do
    desc 'Array of roles that the user should belong to.'
    def insync? is
      is.sort == should.sort
    end
  end

  def refresh
    if @parameters[:ensure]
      provider.passwd
    else
      debug 'skipping password set'
    end
  end
end
