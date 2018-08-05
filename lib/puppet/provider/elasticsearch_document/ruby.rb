$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..', '..'))

require 'puppet/provider/elastic_rest'

require 'puppet_x/elastic/deep_to_s'

Puppet::Type.type(:elasticsearch_document).provide(
  :ruby,
  :parent => Puppet::Provider::ElasticREST,
  :metadata => :content
) do
  desc 'A REST API based provider to manage Elasticsearch documents.'

  mk_resource_methods

  # Helper to format a remote URL request for Elasticsearch which takes into
  # account path ordering, et cetera.
  def self.format_uri(resource_path, _property_flush = {})
    resource_path
  end

  def self.instances
    raise Puppet::Error, 'instances method not implemented for elasticsearch_document'
  end

  def self.prefetch(resources)
    resources.map do |_, res|
      uri = URI(
        format(
          '%s://%s:%d/%s',
          res[:protocol],
          res[:host],
          res[:port],
          res[:name]
        )
      )
      http = Net::HTTP.new uri.host, uri.port
      req = Net::HTTP::Get.new uri.request_uri

      http.use_ssl = uri.scheme == 'https'
      [[res[:ca_file], :ca_file=], [res[:ca_path], :ca_path=]].each do |arg, method|
        http.send method, arg if arg and http.respond_to? method
      end

      response = rest http, req, res[:validate_tls], res[:timeout], res[:username], res[:password]

      next unless response.respond_to? :code and response.code.to_i == 200

      r = JSON.parse(response.body)
      properties = {
        :name => format('%s/%s/%s', r['_index'], r['_type'], r['_id']),
        :ensure => :present,
        metadata => process_metadata(r['_source']),
        :provider => name
      }
      provider = new(properties)
      res.provider = provider
    end
  end
end
