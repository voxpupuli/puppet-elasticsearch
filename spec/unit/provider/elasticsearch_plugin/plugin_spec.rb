require 'spec_helper'

provider_class = Puppet::Type.type(:elasticsearch_plugin).provider(:plugin)

shared_examples 'plugin provider' do |version, build|
  describe "elasticsearch #{version}" do
    before(:each) do
      provider_class.expects(:es).with('-version').returns(build)
      allow(File).to receive(:open)
      provider.es_version
    end

    describe 'setup' do
      it 'installs with default parameters' do
        provider.expects(:plugin).with([
          '-Des.path.conf=/usr/share/elasticsearch',
          'install',
          [ resource_name ]
        ])
        provider.create
      end

      it 'installs via URLs' do
        resource[:url] = 'http://url/to/my/plugin.zip'
        provider.expects(:plugin).with([
          '-Des.path.conf=/usr/share/elasticsearch',
          'install',
          ['http://url/to/my/plugin.zip'].tap do |args|
            if version.start_with? '1'
              args.unshift(shortname, '--url')
            else
              args
            end
          end
        ])
        provider.create
      end

      it 'installs with a local file' do
        resource[:source] = '/tmp/plugin.zip'
        provider.expects(:plugin).with([
          '-Des.path.conf=/usr/share/elasticsearch',
          'install',
          ['file:///tmp/plugin.zip'].tap do |args|
            if version.start_with? '1'
              args.unshift(shortname, '--url')
            else
              args
            end
          end
        ])
        provider.create
      end

      it 'installs behind a proxy' do
        resource[:proxy_args] = '-dproxyport=3128 -dproxyhost=localhost'
        provider.expects(:plugin).with([
          ['-dproxyport=3128', '-dproxyhost=localhost'],
          '-Des.path.conf=/usr/share/elasticsearch',
          'install', [resource_name]
        ])
        provider.create
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
        provider.expects(:plugin).with(['remove', resource_name])
        provider.destroy
      end
    end
  end
end

describe provider_class do

  let(:resource_name) { 'lmenezes/elasticsearch-kopf' }
  let(:resource) do
    Puppet::Type.type(:elasticsearch_plugin).new(
      :name     => resource_name,
      :ensure   => :present,
      :provider => 'plugin'
    )
  end
  let(:provider) do
    provider = provider_class.new
    provider.resource = resource
    provider
  end
  let(:shortname) { provider.plugin_name(resource_name) }

  include_examples 'plugin provider',
    '1.x',
    'Version: 1.7.1, Build: b88f43f/2015-07-29T09:54:16Z, JVM: 1.7.0_79'

  include_examples 'plugin provider',
    '2.x',
    'Version: 2.0.0, Build: de54438/2015-10-22T08:09:48Z, JVM: 1.8.0_66'
end
