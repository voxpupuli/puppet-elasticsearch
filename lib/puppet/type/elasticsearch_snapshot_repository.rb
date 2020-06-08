$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..'))

require 'puppet_x/elastic/elasticsearch_rest_resource'

Puppet::Type.newtype(:elasticsearch_snapshot_repository) do
  extend ElasticsearchRESTResource

  desc 'Manages Elasticsearch snapshot repositories.'

  ensurable

  newparam(:name, :namevar => true) do
    desc 'Repository name.'
  end

  newparam(:type) do
    desc 'Repository type'
    defaultto 'fs'

    validate do |value|
      raise Puppet::Error, 'string expected' unless value.is_a? String
    end
  end

  # newproperty(:compress, :boolean => true, :parent => Puppet::Property::Boolean) do
  newproperty(:compress, :boolean => true) do
    desc 'Compress the repository data'

    defaultto :true
  end

  newproperty(:location) do
    desc 'Repository location'
  end

  newproperty(:client) do
    defaultto 'default'
    desc 'Azure client'
  end

  newproperty(:container) do
    desc 'Azure storage container'
  end

  newproperty(:base_path) do
    desc 'Specifies the path within container to repository data.'
  end

  newproperty(:readonly) do
    defaultto 'false'
    desc 'Makes repository read-only.'
  end

  newproperty(:location_mode) do
    defaultto 'primary_only'
    desc 'primary_only or secondary_only. Note that if you set it to secondary_only, it will force readonly to true.'
  end

  newproperty(:chunk_size) do
    desc 'File chunk size'
  end

  newproperty(:max_restore_rate) do
    desc 'Maximum Restore rate'
  end

  newproperty(:max_snapshot_rate) do
    desc 'Maximum Snapshot rate'
  end

  validate do
    if self[:type] == 'fs'
      raise ArgumentError, 'Location is required.' if self[:location].nil?
    elsif self[:type] == 'azure'
      raise ArgumentError, 'Container is required.' if self[:container].nil?
    end
  end
end # of newtype
