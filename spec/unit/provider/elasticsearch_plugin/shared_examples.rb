require 'puppet/util/package'

shared_examples 'plugin provider' do |version|
  describe "elasticsearch #{version}" do
    before(:each) do
      allow(File).to receive(:open)
      allow(provider).to receive(:es_version).and_return version
    end

    describe 'setup' do
      it 'installs with default parameters' do
        provider.expects(:plugin).with(
          ['install', resource_name].tap do |args|
            if Puppet::Util::Package.versioncmp(version, '2.2.0') >= 0
              args.insert 1, '--batch'
            end
          end
        )
        provider.create
      end

      it 'installs via URLs' do
        resource[:url] = 'http://url/to/my/plugin.zip'
        provider.expects(:plugin).with(
          ['install'] + ['http://url/to/my/plugin.zip'].tap do |args|
            args.unshift('kopf', '--url') if version.start_with? '1'

            if Puppet::Util::Package.versioncmp(version, '2.2.0') >= 0
              args.unshift '--batch'
            end

            args
          end
        )
        provider.create
      end

      it 'installs with a local file' do
        resource[:source] = '/tmp/plugin.zip'
        provider.expects(:plugin).with(
          ['install'] + ['file:///tmp/plugin.zip'].tap do |args|
            args.unshift('kopf', '--url') if version.start_with? '1'

            if Puppet::Util::Package.versioncmp(version, '2.2.0') >= 0
              args.unshift '--batch'
            end

            args
          end
        )
        provider.create
      end

      describe 'proxying' do
        it 'installs behind a proxy' do
          resource[:proxy] = 'http://localhost:3128'
          if version.start_with? '2'
            provider
              .expects(:plugin)
              .with([
                '-Dhttp.proxyHost=localhost',
                '-Dhttp.proxyPort=3128',
                '-Dhttps.proxyHost=localhost',
                '-Dhttps.proxyPort=3128',
                'install',
                resource_name
              ])
            provider.create
          else
            expect(provider.with_environment do
              ENV['ES_JAVA_OPTS']
            end).to eq([
              '-Dhttp.proxyHost=localhost',
              '-Dhttp.proxyPort=3128',
              '-Dhttps.proxyHost=localhost',
              '-Dhttps.proxyPort=3128'
            ].join(' '))
          end
        end

        it 'uses authentication credentials' do
          resource[:proxy] = 'http://elastic:password@es.local:8080'
          if version.start_with? '2'
            provider
              .expects(:plugin)
              .with([
                '-Dhttp.proxyHost=es.local',
                '-Dhttp.proxyPort=8080',
                '-Dhttp.proxyUser=elastic',
                '-Dhttp.proxyPassword=password',
                '-Dhttps.proxyHost=es.local',
                '-Dhttps.proxyPort=8080',
                '-Dhttps.proxyUser=elastic',
                '-Dhttps.proxyPassword=password',
                'install',
                resource_name
              ])
            provider.create
          else
            expect(provider.with_environment do
              ENV['ES_JAVA_OPTS']
            end).to eq([
              '-Dhttp.proxyHost=es.local',
              '-Dhttp.proxyPort=8080',
              '-Dhttp.proxyUser=elastic',
              '-Dhttp.proxyPassword=password',
              '-Dhttps.proxyHost=es.local',
              '-Dhttps.proxyPort=8080',
              '-Dhttps.proxyUser=elastic',
              '-Dhttps.proxyPassword=password'
            ].join(' '))
          end
        end
      end
    end # of setup

    describe 'plugin_name' do
      let(:resource_name) { 'appbaseio/dejaVu' }

      it 'maintains mixed-case names' do
        expect(provider.pluginfile).to include('dejaVu')
      end
    end

    describe 'removal' do
      it 'uninstalls the plugin' do
        provider.expects(:plugin).with(
          ['remove', resource_name.split('-').last]
        )
        provider.destroy
      end
    end
  end
end
