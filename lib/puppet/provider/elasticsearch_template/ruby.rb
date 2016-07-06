require 'json'
require 'net/http'
require 'openssl'

Puppet::Type.type(:elasticsearch_template).provide(:ruby) do
  desc <<-ENDHEREDOC
    A REST API based provider to manage Elasticsearch templates.
  ENDHEREDOC

  mk_resource_methods

  def self.templates scheme='http', host='localhost', port=9200
    uri = URI("#{scheme}://#{host}:#{port}/_template")
    http = Net::HTTP.new uri.host, uri.port
    response = http.request_get(uri.request_uri)
    if response.code == 200
      JSON.parse(response.body).map do |name, template|
        {
          :name => name,
          :ensure => :present,
          :provider => :ruby,
          :content => template
        }
      end
    else
      []
    end
  end

  def self.instances
    templates.map { |resource| new resource }
  end

  def self.prefetch(resources)
    instances.each do |prov|
      if resource = resources[prov.name]
        resource.provider = prov
      end
    end
  end

  def initialize(value={})
    super(value)
    @property_flush = {}
  end

  def flush
    uri = URI(
      "http%s://%s:%d/_template/%s" % [
      (resource.ssl? ? 's' : ''),
      resource[:host],
      resource[:port],
      resource[:name]
    ])
    http = Net::HTTP.new uri.host, uri.port
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE if not resource.ssl_verify?

    case @property_flush[:ensure]
    when :absent
      req = Net::HTTP::Delete.new uri.request_uri
    else
      req = Net::HTTP::Put.new uri.request_uri
      req.body = JSON.generate(resource[:content])
    end

    if resource[:username] and resource[:password]
      req.basic_auth resource[:username], resource[:password]
    elsif resource[:username] or resource[:password]
      Puppet.warning (
        'username and password must both be defined, skipping basic auth'
      )
    end

    response = http.request req

    unless response.code.to_s == '200'
      raise(
        Puppet::Error,
        "Elasticsearch API responded with HTTP #{response.code}"
      )
    end

    @property_hash = self.class.templates.detect do |t|
      t[:name] == resource[:name]
    end
  end

  def create
    @property_flush[:ensure] = :present
  end

  def exists?
    @property_hash[:ensure] == :present
  end

  def destroy
    @property_flush[:ensure] = :absent
  end

end # of .provide
