# frozen_string_literal: true

require 'spec_helper'

describe 'jvm.options.epp' do
  let :harness do
    TemplateHarness.new(
      'templates/etc/elasticsearch/jvm.options.d/jvm.options.epp'
    )
  end

  it 'render the same string each time' do
    harness.set(
      '@_sorted_jvm_options', [
        '-Xms2g',
        '-Xmx2g'
      ]
    )

    first_render = harness.run
    second_render = harness.run

    expect(first_render).to eq(second_render)
  end

  it 'test content' do
    harness.set(
      '@_sorted_jvm_options', [
        '-Xms2g',
        '-Xmx2g'
      ]
    )

    expect(harness.run).to eq(%(
      ### MANAGED BY PUPPET ###
      -Xms2g
      -Xmx2g
    ).config)
  end
end
