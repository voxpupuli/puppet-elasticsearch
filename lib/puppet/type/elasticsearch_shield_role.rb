Puppet::Type.newtype(:elasticsearch_shield_role) do
  desc "Type to model Elasticsearch shield roles."

  ensurable do
    defaultvalues
    defaultto :present
  end

  newparam(:name, :namevar => true) do
    desc 'Role name.'
  end

  newproperty(:privileges) do
    desc 'Security privileges of the given role.'
  end
end
