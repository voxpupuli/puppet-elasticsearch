shared_examples 'manifest application' do |instances, idempotency_check = true|
  context "#{instances.count}-node manifest" do
    let(:applied_manifest) do
      instance_manifest = instances.map do |instance, parameters|
        <<-MANIFEST
          elasticsearch::instance { '#{instance}':
            ensure => #{parameters.empty? ? 'absent' : 'present'},
            #{parameters.map { |k, v| "#{k} => #{v}," }.join("\n")}
            #{defined?(manifest_instance_parameters) && manifest_instance_parameters}
          }
        MANIFEST
      end.join("\n")

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

        #{defined?(skip_instance_manifests) || instance_manifest}

        #{defined?(extra_manifest) && extra_manifest}
      MANIFEST
    end

    it 'applies cleanly' do
      apply_manifest applied_manifest, :catch_failures => true
    end

    if idempotency_check
      it 'is idempotent', :logs_on_failure do
        apply_manifest applied_manifest, :catch_changes => true
      end
    end
  end
end
