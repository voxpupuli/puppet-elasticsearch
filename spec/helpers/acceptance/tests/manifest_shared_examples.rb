shared_examples 'manifest application' do |instances|
  context "#{instances.count}-node manifest" do
    let(:applied_manifest) do
      instance_manifest = instances.map do |instance, meta|
        config = meta.map { |k, v| "'#{k}' => '#{v}'," }.join(' ')
        <<-MANIFEST
          elasticsearch::instance { '#{instance}':
            ensure => #{meta.empty? ? 'absent' : 'present'},
            config => {
              #{config}
            },
            #{defined?(manifest_instance_parameters) && manifest_instance_parameters}
          }
        MANIFEST
      end.join("\n")

      <<-MANIFEST
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

    it 'is idempotent' do
      apply_manifest applied_manifest, :catch_changes => true
    end
  end
end
