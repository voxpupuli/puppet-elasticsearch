# frozen_string_literal: true

require 'json'
require 'helpers/acceptance/tests/manifest_shared_examples'
require 'helpers/acceptance/tests/bad_manifest_shared_examples'

# Describes how to apply a manifest with a template, verify it, and clean it up
shared_examples 'template application' do |es_config, name, template, param|
  context 'present' do
    let(:extra_manifest) do
      <<-MANIFEST
        elasticsearch::template { '#{name}':
          ensure => 'present',
          #{param}
        }
      MANIFEST
    end

    include_examples('manifest application')

    include_examples('template content', es_config, template)
  end

  context 'absent' do
    let(:extra_manifest) do
      <<-MANIFEST
        elasticsearch::template { '#{name}':
          ensure => absent,
        }
      MANIFEST
    end

    include_examples('manifest application')
  end
end

# Verifies the content of a loaded index template.
shared_examples 'template content' do |es_config, template|
  elasticsearch_port = es_config['http.port']
  describe port(elasticsearch_port) do
    it 'open', :with_retries do
      expect(subject).to be_listening
    end
  end

  describe "http://localhost:#{elasticsearch_port}/_template" do
    subject { shell("curl http://localhost:#{elasticsearch_port}/_template") }

    it 'returns the installed template', :with_retries do
      expect(JSON.parse(subject.stdout).values).
        to include(include(template))
    end
  end
end

# Main entrypoint for template tests
shared_examples 'template operations' do |es_config, template|
  describe 'template resources' do
    before :all do # rubocop:disable RSpec/BeforeAfterAll
      shell "mkdir -p #{default['distmoduledir']}/another/files"

      create_remote_file(
        default,
        "#{default['distmoduledir']}/another/files/good.json",
        JSON.dump(template)
      )

      create_remote_file(
        default,
        "#{default['distmoduledir']}/another/files/bad.json",
        JSON.dump(template)[0..-5]
      )
    end

    context 'configured through' do
      context '`source`' do
        include_examples(
          'template application',
          es_config,
          SecureRandom.hex(8),
          template,
          "source => 'puppet:///modules/another/good.json'"
        )
      end

      context '`content`' do
        include_examples(
          'template application',
          es_config,
          SecureRandom.hex(8),
          template,
          "content => '#{JSON.dump(template)}'"
        )
      end

      context 'bad json' do
        let(:extra_manifest) do
          <<-MANIFEST
            elasticsearch::template { '#{SecureRandom.hex(8)}':
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
