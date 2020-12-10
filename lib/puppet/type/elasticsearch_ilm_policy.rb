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
    end

    munge do |value|
      Puppet_X::Elastic.deep_to_i(value)
    end

    def default_compare(is, should)
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
      defshould = should.tap do |val|
        val['policy'] = val['policy'].tap do |policy|
          if policy.key? 'phases'
            # Iterate phases and apply defaults
            policy['phases'] = Hash[policy['phases'].map do |phase_name, phase|
              # Limit negative min_age to 0ms
              if phase.key? 'min_age'
                phase['min_age'] = '0ms' if phase['min_age'].start_with? '-'
              end

              # Iterate actions and apply defaults
              if phase.key? 'actions'
                phase['actions'] = Hash[phase['actions'].map do |action_name, action|
                  case action_name
                  when 'allocate'
                    [action_name, { 'include' => {}, 'exclude' => {}, 'require' => {} }.merge(action)]
                  when ->(a) { a == 'delete' && is7x? }
                    [action_name, { 'delete_searchable_snapshot' => true }.merge(action)]
                  else
                    [action_name, action]
                  end
                end]
              end

              [phase_name, { 'min_age' => '0ms' }.merge(phase)]
            end]
          end # if phases
        end # tap policy
      end # tap is

      Puppet_X::Elastic.deep_implode(is) == \
        Puppet_X::Elastic.deep_implode(defshould)
    end

    def insync?(is)
      default_compare(is, should)
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

  newparam(:source) do
    desc 'Puppet source to file containing policy contents.'

    validate do |value|
      raise Puppet::Error, 'string expected' unless value.is_a? String
    end
  end

  # rubocop:disable Style/SignalException
  validate do
    # Ensure that at least one source of policy content has been provided
    if self[:ensure] == :present
      fail Puppet::ParseError, '"content" or "source" required' \
        if self[:content].nil? and self[:source].nil?
      if !self[:content].nil? and !self[:source].nil?
        fail(
          Puppet::ParseError,
          "'content' and 'source' cannot be simultaneously defined"
        )
      end
    end

    # If a source was passed, retrieve the source content from Puppet's
    # FileServing indirection and set the content property
    unless self[:source].nil?
      unless Puppet::FileServing::Metadata.indirection.find(self[:source])
        fail(format('Could not retrieve source %s', self[:source]))
      end

      if !self.catalog.nil? \
          and self.catalog.respond_to?(:environment_instance)
        tmp = Puppet::FileServing::Content.indirection.find(
          self[:source],
          :environment => self.catalog.environment_instance
        )
      else
        tmp = Puppet::FileServing::Content.indirection.find(self[:source])
      end

      fail(format('Could not find any content at %s', self[:source])) unless tmp
      self[:content] = PSON.load(tmp.content)
    end
  end
end # of newtype
