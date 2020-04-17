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

  newproperty(:bucket) do
    desc 'S3 bucket'
  end

  newproperty(:region) do
    desc 'S3 region'
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
    elsif self[:type] == 's3'
      raise ArgumentError, 'Bucket is required.' if self[:bucket].nil?
    end
  end
end # of newtype
