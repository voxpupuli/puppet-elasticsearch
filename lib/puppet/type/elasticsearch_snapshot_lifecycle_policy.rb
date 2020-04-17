$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..'))

require 'puppet_x/elastic/elasticsearch_rest_resource'

Puppet::Type.newtype(:elasticsearch_snapshot_lifecycle_policy) do
  extend ElasticsearchRESTResource

  desc 'Manages Elasticsearch snapshot lifecycle policies.'

  ensurable

  newparam(:name, :namevar => true) do
    desc 'Lifecycle policy name.'
  end

  newproperty(:schedule_time) do
    desc 'Schedule'
  end

  newproperty(:repository) do
    desc 'Repository name'
  end

  newproperty(:snapshot_name) do
    desc 'Snapshot name'
  end

  newproperty(:config_include_global_state, :boolean => false) do
    desc 'Include global state'

    defaultto :false
  end

  newproperty(:config_ignore_unavailable, :boolean => false) do
    desc 'Ignore unavailable shards'

    defaultto :false
  end

  newproperty(:config_partial, :boolean => false) do
    desc 'Allow partial snapshots'

    defaultto :false
  end

  newproperty(:config_indices) do
    desc 'Indices to snapshot'
  end

  newproperty(:retention_expire_after) do
    desc 'Expire snapshots after time'
  end

  newproperty(:retention_min_count) do
    desc 'Minimum snapshots'
  end

  newproperty(:retention_max_count) do
    desc 'Maximum snaphots'
  end

  validate do
    raise ArgumentError, 'schedule_time is required.' if self[:schedule_time].nil?
    raise ArgumentError, 'repository is required.' if self[:repository].nil?
    raise ArgumentError, 'snapshot_name is required.' if self[:snapshot_name].nil?
  end
end # of newtype
