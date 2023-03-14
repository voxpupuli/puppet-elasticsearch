# frozen_string_literal: true

require 'json'
require 'helpers/acceptance/tests/manifest_shared_examples'
require 'helpers/acceptance/tests/bad_manifest_shared_examples'

# Describes how to apply a manifest with a ILM policy, verify it, and clean it up
shared_examples 'ILM policy application' do |es_config, name, ilm_policy, param|
  context 'present' do
    let(:extra_manifest) do
      <<-MANIFEST
        elasticsearch::ilm_policy { '#{name}':
          ensure => 'present',
          #{param}
        }
      MANIFEST
    end

    include_examples('manifest application')

    include_examples('ILM policy content', es_config, ilm_policy, name)
  end

  context 'absent' do
    let(:extra_manifest) do
      <<-MANIFEST
        elasticsearch::ilm_policy { '#{name}':
          ensure => absent,
        }
      MANIFEST
    end

    include_examples('manifest application')
  end
end

# Verifies the content of a loaded ILM policy.
shared_examples 'ILM policy content' do |es_config, ilm_policy, _name|
  elasticsearch_port = es_config['http.port']
  describe port(elasticsearch_port) do
    it 'open', :with_retries do
      expect(subject).to be_listening
    end
  end

  describe "http://localhost:#{elasticsearch_port}/_ilm/policy" do
    subject { shell("curl http://localhost:#{elasticsearch_port}/_ilm/policy") }

    it 'returns the configured ILM policy', :with_retries do
      expect(JSON.parse(subject.stdout).values).
        to include(include(ilm_policy))
    end
  end
end

# Main entrypoint for ILM policy tests
shared_examples 'ILM policy operations' do |es_config, ilm_policy|
  describe 'policy resources' do
    before :all do # rubocop:disable RSpec/BeforeAfterAll
      shell "mkdir -p #{default['distmoduledir']}/another/files"

      create_remote_file(
        default,
        "#{default['distmoduledir']}/another/files/good.json",
        JSON.dump(ilm_policy)
      )

      create_remote_file(
        default,
        "#{default['distmoduledir']}/another/files/bad.json",
        JSON.dump(ilm_policy)[0..-5]
      )
    end

    context 'configured through' do
      context '`source`' do
        include_examples(
          'ILM policy application',
          es_config,
          SecureRandom.hex(8),
          ilm_policy,
          "source => 'puppet:///modules/another/good.json'"
        )
      end

      context '`content`' do
        include_examples(
          'ILM policy application',
          es_config,
          SecureRandom.hex(8),
          ilm_policy,
          "content => '#{JSON.dump(ilm_policy)}'"
        )
      end

      context 'bad json' do
        let(:extra_manifest) do
          <<-MANIFEST
            elasticsearch::ilm_policy { '#{SecureRandom.hex(8)}':
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
