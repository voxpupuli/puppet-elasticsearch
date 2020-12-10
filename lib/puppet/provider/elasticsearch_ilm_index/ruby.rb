require 'erb'

require 'puppet/provider/elastic_rest'

Puppet::Type.type(:elasticsearch_ilm_index).provide(
  :ruby,
  :parent => Puppet::Provider::ElasticREST,
  :metadata => :content,
  :api_uri => '_settings',
  :api_discovery_uri => '_all',
  :api_resource_style => :prefix,
  :discrete_resource_creation => true,
  :creation_alias => lambda { |res|
    value = "#{res[:name]}-#{res[:pattern]}"
    # if this uses date math it must be wrapped in angle brackets
    value = "<#{value}>" if value.include?('{')
    # URI encode so that it can be put in the REST request URI
    ERB::Util.url_encode(value)
  },
  :deletion_alias => lambda { |res| "#{res[:name]}-*" },
  :body_parser => lambda { |body|
    # Return a hash of proxy objects representing each ILM managed index set
    body
      .map { |_, value| value.dig('settings', 'index', 'lifecycle', 'rollover_alias') }
      .uniq
      .reject(&:nil?)
      .map { |name| { name => { 'exists' => true } } }
      .reduce({}, &:merge)
  }
) do
  desc 'A REST API based provider to manage Elasticsearch ILM managed index sets.'

  mk_resource_methods
end
