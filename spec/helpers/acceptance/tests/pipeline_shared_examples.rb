require 'json'
require 'helpers/acceptance/tests/manifest_shared_examples'
require 'helpers/acceptance/tests/bad_manifest_shared_examples'

shared_examples 'pipeline operations' do |instances, pipeline|
  describe 'pipeline resources' do
    let(:pipeline_name) { 'foo' }
    context 'present' do
      let(:extra_manifest) do
        <<-MANIFEST
          elasticsearch::pipeline { '#{pipeline_name}':
            ensure  => 'present',
            content => #{pipeline}
          }
        MANIFEST
      end

      include_examples(
        'manifest application',
        instances
      )

      context 'absent' do
        let(:extra_manifest) do
          <<-MANIFEST
            elasticsearch::template { '#{pipeline_name}':
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
  end
end
