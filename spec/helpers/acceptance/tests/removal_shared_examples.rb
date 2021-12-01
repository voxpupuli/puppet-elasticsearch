# frozen_string_literal: true

shared_examples 'module removal' do |es_config|
  describe 'uninstalling' do
    let(:manifest) do
      <<-MANIFEST
        class { 'elasticsearch': ensure => 'absent', oss => #{v[:oss]} }
      MANIFEST
    end

    it 'runs successfully' do
      apply_manifest(manifest, catch_failures: true, debug: v[:puppet_debug])
    end

    describe package("elasticsearch#{v[:oss] ? '-oss' : ''}") do
      it { is_expected.not_to be_installed }
    end

    describe service('elasticsearch') do
      it { is_expected.not_to be_enabled }
      it { is_expected.not_to be_running }
    end

    unless es_config.empty?
      describe port(es_config['http.port']) do
        it 'closed' do
          expect(subject).not_to be_listening
        end
      end
    end
  end
end
