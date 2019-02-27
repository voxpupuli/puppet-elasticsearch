shared_examples 'module removal' do |instances|
  describe 'uninstalling' do
    let(:manifest) do
      instance_resource = <<-RESOURCE
        elasticsearch::instance { '%s' :
          ensure => 'absent'
        }
      RESOURCE

      <<-MANIFEST
        class { 'elasticsearch': ensure => 'absent', oss => #{v[:oss]} }
        #{instances.map { |i| instance_resource % i }.join("\n")}
      MANIFEST
    end

    it 'should run successfully' do
      apply_manifest manifest, :catch_failures => true
    end

    it 'is idempotent' do
      apply_manifest manifest, :catch_changes => true
    end

    instances.each do |instance|
      describe file("/etc/elasticsearch/#{instance}") do
        it { should_not be_directory }
      end

      describe service(instance) do
        it { should_not be_enabled }
        it { should_not be_running }
      end
    end
  end
end
