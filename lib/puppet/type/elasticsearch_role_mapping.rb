# frozen_string_literal: true

Puppet::Type.newtype(:elasticsearch_role_mapping) do
  desc 'Type to model Elasticsearch role mappings.'

  ensurable

  newparam(:name, namevar: true) do
    desc 'Role name.'

    newvalues(%r{^[a-zA-Z_]{1}[-\w@.$]{0,39}$})
  end

  newproperty(:mappings, array_matching: :all) do
    desc 'List of role mappings.'
  end
end
