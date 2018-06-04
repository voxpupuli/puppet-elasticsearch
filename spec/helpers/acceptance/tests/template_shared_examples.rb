require 'json'
require 'helpers/acceptance/tests/manifest_shared_examples'
require 'helpers/acceptance/tests/bad_manifest_shared_examples'

# Describes how to apply a manifest with a template, verify it, and clean it up
shared_examples 'template application' do |instances, name, template, param|
  context 'present' do
    let(:extra_manifest) do
      <<-MANIFEST
        elasticsearch::template { '#{name}':
          ensure => 'present',
          #{param}
        }
      MANIFEST
    end

    include_examples(
      'manifest application',
      instances
    )

    include_examples 'template content', instances, template
  end

  context 'absent' do
    let(:extra_manifest) do
      <<-MANIFEST
        elasticsearch::template { '#{name}':
          ensure => absent,
        }
      MANIFEST
    end

    include_examples(
      'manifest application',
      instances
    )
  end
end

# Verifies the content of a loaded index template.
shared_examples 'template content' do |instances, template|
  instances.each_value do |i|
    describe port(i['config']['http.port']) do
      it 'open', :with_retries do
        should be_listening
      end
    end

    describe server :container do
      describe http(
        "http://localhost:#{i['config']['http.port']}/_template",
        :params => { 'flat_settings' => 'false' }
      ) do
        it 'returns the installed template', :with_retries do
          expect(JSON.parse(response.body).values)
            .to include(include(template))
        end
      end
    end
  end
end

# Main entrypoint for template tests
shared_examples 'template operations' do |instances, template|
  describe 'template resources' do
    before :all do
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
          instances,
          SecureRandom.hex(8),
          template,
          "source => 'puppet:///modules/another/good.json'"
        )
      end

      context '`content`' do
        include_examples(
          'template application',
          instances,
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

        include_examples(
          'invalid manifest application',
          instances
        )
      end
    end
  end
end
