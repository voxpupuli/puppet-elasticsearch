shared_examples 'manifest application' do |instances, extra_manifest = ''|
  context "#{instances.count}-node manifest" do
    let(:applied_manifest) do
      manifest + instances.map do |instance, meta|
        config = meta.map { |k, v| "'#{k}' => '#{v}'," }.join(' ')
        <<-MANIFEST
          elasticsearch::instance { '#{instance}':
            config => {
              #{config}
            }
          }
        MANIFEST
      end.join("\n") + extra_manifest
    end

    it 'applies cleanly' do
      apply_manifest applied_manifest, :catch_failures => true
    end

    it 'is idempotent' do
      apply_manifest applied_manifest, :catch_changes => true
    end
  end
end
