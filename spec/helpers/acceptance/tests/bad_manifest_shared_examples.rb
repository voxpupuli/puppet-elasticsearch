# frozen_string_literal: true

shared_examples 'invalid manifest application' do
  context 'bad manifest' do
    let(:applied_manifest) do
      <<-MANIFEST
        class { 'elasticsearch' :
          #{manifest}
          #{defined?(manifest_class_parameters) && manifest_class_parameters}
        }

        #{defined?(extra_manifest) && extra_manifest}
      MANIFEST
    end

    it 'fails to apply' do
      apply_manifest(applied_manifest, expect_failures: true, debug: v[:puppet_debug])
    end
  end
end
