require 'tempfile'
require 'helpers/acceptance/tests/basic_shared_examples'
require 'helpers/acceptance/tests/plugin_shared_examples'

shared_examples 'hiera tests with' do |yamlname, instances, additional_yaml = {}|
  before :all do
    Tempfile.create([yamlname, '.yaml']) do |temp|
      temp << {
        'elasticsearch::instances' => instances.map do |instance, config|
          [instance, { 'config' => config }]
        end.to_h
      }.merge(additional_yaml).to_yaml
      temp.flush

      File.basename(temp.path).tap do |config|
        scp_to(
          default,
          temp.path,
          File.join(hiera_datadir(default), config)
        )
        write_hiera_config([config])
      end
    end
  end

  include_examples(
    'basic acceptance tests',
    instances
  )
end

shared_examples 'hiera acceptance tests' do
  describe 'hiera' do
    before :all do
      shell "mkdir -p #{hiera_datadir(default)}"
    end

    let(:skip_instance_manifests) { true }
    let(:manifest_class_parameters) { 'restart_on_change => true' }

    describe 'with one instance' do
      include_examples(
        'hiera tests with',
        'singleinstance',
        'es-hiera-single' => {
          'node.name' => 'es-hiera-single',
          'http.port' => 9200
        }
      )
    end

    describe 'with one plugin' do
      include_examples(
        'hiera tests with',
        'singleplugin',
        {
          'es-hiera-single' => {
            'node.name' => 'es-hiera-single',
            'http.port' => 9200
          }
        },
        'elasticsearch::plugins' => {
          'mobz/elasticsearch-head' => {
            'ensure' => 'present',
            'module_dir' => 'head',
            'instances' => [
              'es-hiera-single'
            ]
          }
        }
      )

      include_examples(
        'plugin API response',
        {
          'es-hiera-single' => {
            'node.name' => 'es-hiera-single',
            'http.port' => 9200
          }
        },
        'installs the plugin',
        'name' => 'head'
      )
    end

    describe 'with two instances' do
      include_examples(
        'hiera tests with',
        'multipleinstances',
        'es-hiera-multiple-1' => {
          'node.name' => 'es-hiera-multiple-1',
          'network.host' => '0.0.0.0',
          'http.port' => 9201
        },
        'es-hiera-multiple-2' => {
          'node.name' => 'es-hiera-multiple-2',
          'network.host' => '0.0.0.0',
          'http.port' => 9202
        }
      )
    end

    after :all do
      write_hiera_config([])

      apply_manifest <<-EOS
        class { 'elasticsearch': ensure => 'absent' }
        Elasticsearch::Instance { ensure => 'absent' }
        elasticsearch::instance { 'es-hiera-single': }
        elasticsearch::instance { 'es-hiera-multiple-1': }
        elasticsearch::instance { 'es-hiera-multiple-2': }
      EOS
    end
  end
end
