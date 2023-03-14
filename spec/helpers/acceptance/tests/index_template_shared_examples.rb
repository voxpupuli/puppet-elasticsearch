# frozen_string_literal: true

require 'json'
require 'helpers/acceptance/tests/manifest_shared_examples'
require 'helpers/acceptance/tests/bad_manifest_shared_examples'

# Describes how to apply a manifest with an index template, verify it, and clean it up
shared_examples 'index template application' do |es_config, name, index_template, param|
  context 'present' do
    let(:extra_manifest) do
      <<-MANIFEST
        elasticsearch::index_template { '#{name}':
          ensure => 'present',
          #{param}
        }
      MANIFEST
    end

    include_examples('manifest application')

    include_examples('index template content', es_config, index_template, name)
  end

  context 'absent' do
    let(:extra_manifest) do
      <<-MANIFEST
        elasticsearch::index_template { '#{name}':
          ensure => absent,
        }
      MANIFEST
    end

    include_examples('manifest application')
  end
end

# Verifies the content of a loaded index template.
shared_examples 'index template content' do |es_config, index_template, name|
  elasticsearch_port = es_config['http.port']
  describe port(elasticsearch_port) do
    it 'open', :with_retries do
      expect(subject).to be_listening
    end
  end

  describe "http://localhost:#{elasticsearch_port}/_index_template/#{name}" do
    subject { shell("curl -s http://localhost:#{elasticsearch_port}/_index_template/#{name}") }

    it 'returns the installed index template', :with_retries do
      expect(JSON.parse(subject.stdout)['index_templates']).
        to include(include('name' => name, 'index_template' => index_template))
    end
  end
end

# Main entrypoint for index template tests
shared_examples 'index template operations' do |es_config, index_template|
  describe 'template resources' do
    before :all do # rubocop:disable RSpec/BeforeAfterAll
      shell "mkdir -p #{default['distmoduledir']}/another/files"

      create_remote_file(
        default,
        "#{default['distmoduledir']}/another/files/good.json",
        JSON.dump(index_template)
      )

      create_remote_file(
        default,
        "#{default['distmoduledir']}/another/files/bad.json",
        JSON.dump(index_template)[0..-5]
      )
    end

    context 'configured through' do
      context '`source`' do
        include_examples(
          'index template application',
          es_config,
          SecureRandom.hex(8),
          index_template,
          "source => 'puppet:///modules/another/good.json'"
        )
      end

      context '`content`' do
        include_examples(
          'index template application',
          es_config,
          SecureRandom.hex(8),
          index_template,
          "content => '#{JSON.dump(index_template)}'"
        )
      end

      context 'bad json' do
        let(:extra_manifest) do
          <<-MANIFEST
            elasticsearch::index_template { '#{SecureRandom.hex(8)}':
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
