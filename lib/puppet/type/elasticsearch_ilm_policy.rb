$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', '..'))

require 'puppet/file_serving/content'
require 'puppet/file_serving/metadata'

require 'puppet_x/elastic/deep_implode'
require 'puppet_x/elastic/deep_to_i'
require 'puppet_x/elastic/elasticsearch_rest_resource'
require 'puppet_x/elastic/es_versioning'

Puppet::Type.newtype(:elasticsearch_ilm_policy) do
  extend ElasticsearchRESTResource

  desc 'Manages Elasticsearch ILM policies.'

  ensurable

  newparam(:name, :namevar => true) do
    desc 'Policy name.'
  end

  newproperty(:content) do
    desc 'Structured content of policy.'

    validate do |value|
      raise Puppet::Error, 'hash expected' unless value.is_a? Hash

      phases = value.dig('policy', 'phases')
      raise Puppet::Error, 'the policy document seems malformed (expected `policy => phases`)' unless phases
      raise Puppet::Error, 'policy phases must be a hash' unless phases.is_a? Hash
      raise Puppet::Error, 'each phase must have an actions hash' unless phases.all? { |_, p| p.key?('actions') && p['actions'].is_a?(Hash) }
    end

    munge do |value|
      Puppet_X::Elastic.deep_to_i(value)
    end

    def default_policy(policy)
      # The Elasticsearch API will return default values for the
      # following properties. So we run through each phase and
      # action to merge these in before compare.
      #
      # #Phase Defaults
      # - Adds a default time field `min_age` with value `0ms`
      # - If `min_age` is negative, it is set to `0ms`
      #
      # #Action defaults
      #
      # ## allocate
      # - Adds a default hash field `include` with value `{}`
      # - Adds a default hash field `exclude` with value `{}`
      # - Adds a default hash field `require` with value `{}`
      #
      # ## delete
      # - On ES >= 7, adds default bool field `delete_searchable_snapshot` with value `true`
      #

      # Iterate phases and apply defaults
      phases = policy['policy']['phases']
      phases.each do |phase_name, phase|
        if phase.key? 'min_age'
          phase['min_age'] = '0ms' if phase['min_age'].start_with? '-'
        end

        # Iterate actions and apply defaults
        actions = phase['actions']
        actions.each do |action_name, action|
          case action_name
          when 'allocate'
            actions[action_name] = { 'include' => {}, 'exclude' => {}, 'require' => {} }.merge(action)
          when ->(a) { a == 'delete' && is7x? }
            actions[action_name] = { 'delete_searchable_snapshot' => true }.merge(action)
          end
        end

        phases[phase_name] = { 'min_age' => '0ms' }.merge(phase)
      end
    end

    def insync?(is)
      Puppet_X::Elastic.deep_implode(is) == \
        Puppet_X::Elastic.deep_implode(default_policy(should))
    end

    # Determine the installed version of Elasticsearch on this host.
    def es_version
      Puppet_X::Elastic::EsVersioning.version(
        resource[:elasticsearch_package_name], resource.catalog
      )
    end

    def is7x?
      (Puppet::Util::Package.versioncmp(es_version, '7.0.0') >= 0) && (Puppet::Util::Package.versioncmp(es_version, '8.0.0') < 0)
    end
  end

  newparam(:elasticsearch_package_name) do
    desc 'Name of the system Elasticsearch package.'
  end
end # of newtype
