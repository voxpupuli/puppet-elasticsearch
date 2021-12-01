# frozen_string_literal: true

shared_examples 'manifest application' do |idempotency_check = true|
  context 'manifest' do
    let(:applied_manifest) do
      repo = if elastic_repo
               <<-MANIFEST
                 class { 'elastic_stack::repo':
                   oss => #{v[:oss]},
                   version => #{v[:elasticsearch_major_version]},
                 }
               MANIFEST
             else
               ''
             end

      <<-MANIFEST
        #{repo}

        class { 'elasticsearch' :
          #{manifest}
          #{defined?(manifest_class_parameters) && manifest_class_parameters}
        }

        #{defined?(extra_manifest) && extra_manifest}
      MANIFEST
    end

    it 'applies cleanly' do
      apply_manifest(applied_manifest, catch_failures: true, debug: v[:puppet_debug])
    end

    # binding.pry
    if idempotency_check
      it 'is idempotent', :logs_on_failure do
        apply_manifest(applied_manifest, catch_changes: true, debug: v[:puppet_debug])
      end
    end
  end
end
