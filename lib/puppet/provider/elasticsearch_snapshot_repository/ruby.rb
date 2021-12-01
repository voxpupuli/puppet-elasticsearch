$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', '..'))

require 'puppet/provider/elastic_rest'

Puppet::Type.type(:elasticsearch_snapshot_repository).provide(
  :ruby,
  :parent => Puppet::Provider::ElasticREST,
  :api_uri => '_snapshot'
) do
  desc 'A REST API based provider to manage Elasticsearch snapshot repositories.'

  mk_resource_methods

  def self.process_body(body)
    Puppet.debug('Got to snapshot_repository.process_body')

    results = JSON.parse(body).map do |object_name, api_object|
      {
        :name              => object_name,
        :ensure            => :present,
        :type              => api_object['type'],
        :compress          => api_object['settings']['compress'],
        :location          => api_object['settings']['location'],
        :container         => api_object['settings']['container'],
        :base_path         => api_object['settings']['base_path'],
        :client            => api_object['settings']['client'],
        :readonly          => api_object['settigns']['readonly'],
        :location_mode     => api_object['settings']['location_mode'],
        :chunk_size        => api_object['settings']['chunk_size'],
        :max_restore_rate  => api_object['settings']['max_restore_rate'],
        :max_snapshot_rate => api_object['settings']['max_snapshot_rate'],
        :provider          => name
      }.reject { |_k, v| v.nil? }
    end
    results
  end

  def generate_body
    Puppet.debug('Got to snapshot_repository.generate_body')
    # Build core request body
    body = {
      'type'     => resource[:type],
      'settings' => {
        'compress' => resource[:compress]
      }
    }

    # Add optional values
    body['settings']['location'] = resource[:location] unless resource[:location].nil?   
    body['settings']['container'] = resource[:container] unless resource[:container].nil?   
    body['settings']['base_path'] = resource[:base_path] unless resource[:base_path].nil?   
    body['settings']['client'] = resource[:client] unless resource[:client].nil?   
    body['settings']['readonly'] = resource[:readonly] unless resource[:readonly].nil?   
    body['settings']['location_mode'] = resource[:location_mode] unless resource[:location_mode].nil?   
    body['settings']['chunk_size'] = resource[:chunk_size] unless resource[:chunk_size].nil?
    body['settings']['max_restore_rate'] = resource[:max_restore_rate] unless resource[:max_restore_rate].nil?
    body['settings']['max_snapshot_rate'] = resource[:max_snapshot_rate] unless resource[:max_snapshot_rate].nil?

    # Convert to JSON and return
    JSON.generate(body)
  end
end
