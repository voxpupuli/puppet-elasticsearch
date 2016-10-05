Puppet::Type.newtype(:elasticsearch_shield_role_mapping) do
  desc "Type to model Elasticsearch shield role mappings."

  ensurable do
    defaultvalues
    defaultto :present
  end

  newparam(:name, :namevar => true) do
    desc 'Role name.'

    newvalues(/^[a-zA-Z_]{1}[-\w@.$]{0,29}$/)
  end

  newparam(:home_dir) do
    desc 'Root-directory of installation.'

    defaultto '/usr/share/elasticsearch'
    newvalues(/^\/.*[^\/]$/)
  end

  newproperty(:mappings, :array_matching => :all) do
    desc 'List of role mappings.'
  end
end
