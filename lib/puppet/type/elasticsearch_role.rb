# frozen_string_literal: true

Puppet::Type.newtype(:elasticsearch_role) do
  desc 'Type to model Elasticsearch roles.'

  ensurable

  newparam(:name, namevar: true) do
    desc 'Role name.'

    newvalues(%r{^[a-zA-Z_]{1}[-\w@.$]{0,39}$})
  end

  newproperty(:privileges) do
    desc 'Security privileges of the given role.'
  end
end
