shared_examples 'invalid manifest application' do |instances|
  context "bad #{instances.count}-node manifest" do
    let(:applied_manifest) do
      manifest + instances.map do |instance, meta|
        config = meta.map { |k, v| "'#{k}' => '#{v}'," }.join("\n")
        <<-MANIFEST
          elasticsearch::instance { '#{instance}':
            config => {
              #{config}
            }
          }
        MANIFEST
      end.join("\n") + extra_manifest
    end

    it 'fails to apply' do
      apply_manifest applied_manifest, :expect_failures => true
    end
  end
end
