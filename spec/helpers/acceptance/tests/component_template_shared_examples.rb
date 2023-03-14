# frozen_string_literal: true

require 'json'
require 'helpers/acceptance/tests/manifest_shared_examples'
require 'helpers/acceptance/tests/bad_manifest_shared_examples'

# Describes how to apply a manifest with a component template, verify it, and clean it up
shared_examples 'component template application' do |es_config, name, component_template, param|
  context 'present' do
    let(:extra_manifest) do
      <<-MANIFEST
        elasticsearch::component_template { '#{name}':
          ensure => 'present',
          #{param}
        }
      MANIFEST
    end

    include_examples('manifest application')

    include_examples('component template content', es_config, component_template, name)
  end

  context 'absent' do
    let(:extra_manifest) do
      <<-MANIFEST
        elasticsearch::component_template { '#{name}':
          ensure => absent,
        }
      MANIFEST
    end

    include_examples('manifest application')
  end
end

# Verifies the content of a loaded component template.
shared_examples 'component template content' do |es_config, component_template, name|
  elasticsearch_port = es_config['http.port']
  describe port(elasticsearch_port) do
    it 'open', :with_retries do
      expect(subject).to be_listening
    end
  end

  describe "http://localhost:#{elasticsearch_port}/_component_template/#{name}" do
    subject { shell("curl -s http://localhost:#{elasticsearch_port}/_component_template/#{name}") }

    it 'returns the installed component template', :with_retries do
      expect(JSON.parse(subject.stdout)['component_templates']).
        to include(include('name' => name, 'component_template' => component_template))
    end
  end
end

# Main entrypoint for component template tests
shared_examples 'component template operations' do |es_config, component_template|
  describe 'template resources' do
    before :all do # rubocop:disable RSpec/BeforeAfterAll
      shell "mkdir -p #{default['distmoduledir']}/another/files"

      create_remote_file(
        default,
        "#{default['distmoduledir']}/another/files/good.json",
        JSON.dump(component_template)
      )

      create_remote_file(
        default,
        "#{default['distmoduledir']}/another/files/bad.json",
        JSON.dump(component_template)[0..-5]
      )
    end

    context 'configured through' do
      context '`source`' do
        include_examples(
          'component template application',
          es_config,
          SecureRandom.hex(8),
          component_template,
          "source => 'puppet:///modules/another/good.json'"
        )
      end

      context '`content`' do
        include_examples(
          'component template application',
          es_config,
          SecureRandom.hex(8),
          component_template,
          "content => '#{JSON.dump(component_template)}'"
        )
      end

      context 'bad json' do
        let(:extra_manifest) do
          <<-MANIFEST
            elasticsearch::component_template { '#{SecureRandom.hex(8)}':
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
