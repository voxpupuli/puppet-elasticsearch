# frozen_string_literal: true

require 'json'
require 'helpers/acceptance/tests/manifest_shared_examples'
require 'helpers/acceptance/tests/bad_manifest_shared_examples'

# Describes how to apply a manifest with a SLM policy, verify it, and clean it up
shared_examples 'SLM policy application' do |es_config, name, slm_policy, param|
  context 'present' do
    let(:extra_manifest) do
      <<-MANIFEST
        elasticsearch::snapshot_repository { '#{slm_policy['repository']}':
          ensure => 'present',
          location => '/var/lib/elasticsearch/backup'
        }
        elasticsearch::slm_policy { '#{name}':
          ensure => 'present',
          #{param}
        }
      MANIFEST
    end

    include_examples('manifest application')

    include_examples('SLM policy content', es_config, slm_policy, name)
  end

  context 'absent' do
    let(:extra_manifest) do
      <<-MANIFEST
        elasticsearch::slm_policy { '#{name}':
          ensure => absent,
        }
      MANIFEST
    end

    include_examples('manifest application')
  end
end

# Verifies the content of a loaded SLM policy.
shared_examples 'SLM policy content' do |es_config, slm_policy, _name|
  elasticsearch_port = es_config['http.port']
  describe port(elasticsearch_port) do
    it 'open', :with_retries do
      expect(subject).to be_listening
    end
  end

  describe "http://localhost:#{elasticsearch_port}/_slm/policy" do
    subject { shell("curl http://localhost:#{elasticsearch_port}/_slm/policy") }

    it 'returns the configured SLM policy', :with_retries do
      expect(JSON.parse(subject.stdout).values).
        to include(include('policy' => slm_policy))
    end
  end
end

# Main entrypoint for SLM policy tests
shared_examples 'SLM policy operations' do |es_config, slm_policy|
  describe 'policy resources' do
    before :all do # rubocop:disable RSpec/BeforeAfterAll
      shell "mkdir -p #{default['distmoduledir']}/another/files"

      create_remote_file(
        default,
        "#{default['distmoduledir']}/another/files/good.json",
        JSON.dump(slm_policy)
      )

      create_remote_file(
        default,
        "#{default['distmoduledir']}/another/files/bad.json",
        JSON.dump(slm_policy)[0..-5]
      )
    end

    es_config = {
      'http.port' => 9200,
      'node.name' => 'elasticsearchSlm01',
      'path.repo' => '/var/lib/elasticsearch'
    }

    # Override the manifest in order to populate 'path.repo'
    let(:manifest) do
      package = if v[:is_snapshot]
                  <<-MANIFEST
                    manage_repo => false,
                    package_url => '#{v[:snapshot_package]}',
                  MANIFEST
                else
                  <<-MANIFEST
                    # Hard version set here due to plugin incompatibilities.
                    version => '#{v[:elasticsearch_full_version]}',
                  MANIFEST
                end

      <<-MANIFEST
        api_timeout => 60,
        config => {
          'cluster.name' => '#{v[:cluster_name]}',
          'http.bind_host' => '0.0.0.0',
    #{es_config.map { |k, v| "        '#{k}' => '#{v}'," }.join("\n")}
        },
        jvm_options => [
          '-Xms128m',
          '-Xmx128m',
        ],
        oss => #{v[:oss]},
        #{package}
      MANIFEST
    end

    let(:manifest_class_parameters) { 'restart_on_change => true' }

    context 'configured through' do
      context '`source`' do
        include_examples(
          'SLM policy application',
          es_config,
          SecureRandom.hex(8),
          slm_policy,
          "source => 'puppet:///modules/another/good.json'"
        )
      end

      context '`content`' do
        include_examples(
          'SLM policy application',
          es_config,
          SecureRandom.hex(8),
          slm_policy,
          "content => '#{JSON.dump(slm_policy)}'"
        )
      end

      context 'bad json' do
        let(:extra_manifest) do
          <<-MANIFEST
            elasticsearch::slm_policy { '#{SecureRandom.hex(8)}':
              ensure => 'present',
              file => 'puppet:///modules/another/bad.json'
            }
          MANIFEST
        end

        include_examples('invalid manifest application')
      end
    end
  end
end
