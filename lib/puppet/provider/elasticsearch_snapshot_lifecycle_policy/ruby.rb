$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', '..'))

require 'puppet/provider/elastic_rest'

Puppet::Type.type(:elasticsearch_snapshot_lifecycle_policy).provide(
  :ruby,
  :parent => Puppet::Provider::ElasticREST,
  :api_uri => '_slm/policy'
) do
  desc 'A REST API based provider to manage Elasticsearch snapshot lifecycle policy.'

  mk_resource_methods

  def self.process_body(body)
    Puppet.debug('Got to snapshot_lifecycle_policy.process_body')

    results = JSON.parse(body).map do |object_name, api_object|
      {
        :name                         => object_name,
        :ensure                       => :present,
        :schedule_time                => api_object['policy']['schedule'],
        :repository                   => api_object['policy']['repository'],
        :snapshot_name                => api_object['policy']['name'],
        :config_include_global_state  => api_object['policy']['config']['include_global_state'],
        :config_ignore_unavailable    => api_object['policy']['config']['ignore_unavailable'],
        :config_partial               => api_object['policy']['config']['partial'],
        :config_indices               => api_object['policy']['config']['indices'],
        :retention_expire_after       => api_object['policy']['retention']['expire_after'],
        :retention_min_count          => api_object['policy']['retention']['min_count'],
        :retention_max_count          => api_object['policy']['retention']['max_count'],
        :provider                     => name
      }.reject { |_k, v| v.nil? }
    end
    results
  end

  # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
  def generate_body
    Puppet.debug('Got to snapshot_lifecycle_policy.generate_body')
    # Build core request body
    body = {
      'schedule'    => resource[:schedule_time],
      'repository'  => resource[:repository],
      'name'        => resource[:snapshot_name],
      'config'      => {},
      'retention'   => {}
    }

    # Add optional values
    body['config']['include_global_state'] = resource[:config_include_global_state] unless resource[:config_include_global_state].nil?
    body['config']['ignore_unavailable'] = resource[:config_ignore_unavailable] unless resource[:config_ignore_unavailable].nil?
    body['config']['partial'] = resource[:config_partial] unless resource[:config_partial].nil?
    body['config']['indices'] = resource[:config_indices] unless resource[:config_indices].nil?
    body['retention']['expire_after'] = resource[:retention_expire_after] unless resource[:retention_expire_after].nil?
    body['retention']['min_count'] = resource[:retention_min_count] unless resource[:retention_min_count].nil?
    body['retention']['max_count'] = resource[:retention_max_count] unless resource[:retention_max_count].nil?

    # Convert to JSON and return
    JSON.generate(body)
  end
  # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
end
