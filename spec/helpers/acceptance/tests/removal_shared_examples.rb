shared_examples 'module removal' do |es_config|
  describe 'uninstalling' do
    let(:manifest) do
      <<-MANIFEST
        class { 'elasticsearch': ensure => 'absent', oss => #{v[:oss]} }
      MANIFEST
    end

    it 'should run successfully' do
      apply_manifest manifest, :catch_failures => true
    end

    it 'is idempotent' do
      apply_manifest manifest, :catch_changes => true
    end

    describe service('elasticsearch') do
      it { should_not be_enabled }
      it { should_not be_running }
    end

    unless es_config.empty?
      describe port(es_config['http.port']) do
        it 'closed' do
          should_not be_listening
        end
      end
    end
  end
end
