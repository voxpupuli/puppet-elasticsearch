shared_examples 'basic acceptance tests' do |instance|
  context 'manifest' do
    it 'applies cleanly' do
      apply_manifest manifest, :catch_failures => true
    end

    it 'is idempotent' do
      apply_manifest manifest, :catch_changes => true
    end

    describe service("elasticsearch-#{instance}") do
      it { should be_enabled }
      it { should be_running }
    end

    describe package('elasticsearch') do
      it { should be_installed }
    end
  end

    describe file(test_settings['pid_a']) do
      it { should be_file }
      its(:content) { should match(/[0-9]+/) }
    end

    describe file('/etc/elasticsearch/es-01/elasticsearch.yml') do
      it { should be_file }
      it { should contain 'name: elasticsearch001' }
      it { should contain '/var/lib/elasticsearch/es-01' }
    end

    describe file('/usr/share/elasticsearch/templates_import') do
      it { should be_directory }
    end

    describe file('/var/lib/elasticsearch/es-01') do
      it { should be_directory }
    end

    describe file('/usr/share/elasticsearch/scripts') do
      it { should be_directory }
    end

    describe file('/etc/elasticsearch/es-01/scripts') do
      it { should be_symlink }
    end

    describe port(test_settings['port_a']) do
      it 'open', :with_retries do
        should be_listening
      end
    end

    describe server :container do
      describe http(
        "http://localhost:#{test_settings['port_a']}/_nodes/_local"
      ) do
        it 'serves requests', :with_retries do
          expect(response.status).to eq(200)
        end

        it 'uses the default data path' do
          json = JSON.parse(response.body)['nodes'].values.first
          expect(
            json['settings']['path']
          ).to include(
            'data' => '/var/lib/elasticsearch/es-01'
          )
        end
      end
    end
  end

  context 'example manifest' do
    it { apply_manifest(manifest, :catch_failures => true) }
    it { apply_manifest(manifest, :catch_changes  => true) }

    describe package('kibana') do
      it { is_expected.to be_installed }
    end

    describe service('kibana') do
      it { is_expected.to be_enabled }
      it { is_expected.to be_running }
    end

    describe port(5602) { it { should be_listening } }

    describe server :container do
      describe http('http://localhost:5602') do
        it('returns OK', :api) { expect(response.status).to eq(200) }
        it('is live', :api) { expect(response['kbn-name']).to eq('kibana') }
        it 'installs the correct version', :api do
          ver = version.count('-') >= 1 ? version.split('-')[0..-2].join('-') : version
          expect(response['kbn-version']).to eq(ver)
        end
      end
    end
  end
end
