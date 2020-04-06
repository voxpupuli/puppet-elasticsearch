require 'spec_helper'
require 'yaml'

describe 'jvm.options.erb' do
  let(:scope) { PuppetlabsSpec::PuppetInternals.scope }

  before(:each) do
    allow(scope).to receive(:lookupvar).with('elasticsearch::logdir', {}).and_return('/var/log/elasticsearch')
  end

  let(:template) { 'templates/etc/elasticsearch/jvm.options.erb' }

  it 'render the same string each time' do
    harness = TemplateHarness.new(template, scope)
    allow(scope).to receive(:lookupvar).with('elasticsearch::jvm_options', {}).and_return([])

    first_render = harness.run
    second_render = harness.run

    expect(first_render).to eq(second_render)
  end

  it 'removes overriden default values' do
    harness = TemplateHarness.new(template, scope)
    allow(scope).to receive(:lookupvar).with('elasticsearch::jvm_options', {})
      .and_return(['-Xms12g', '-Xmx12g'])

    first_render = harness.run
    second_render = harness.run

    expect(first_render).to eq(second_render)

    expect(first_render).to_not match(/-Xms2g.*-Xmx2g/m)
    expect(first_render).to match(/-Xms12g.*-Xmx12g/m)
  end
end
