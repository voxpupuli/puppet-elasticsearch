# frozen_string_literal: true

require 'spec_helper'
require 'yaml'

class String
  def config
    "### MANAGED BY PUPPET ###\n---#{unindent}"
  end

  def unindent
    gsub(%r{^#{scan(%r{^\s*}).min_by(&:length)}}, '')
  end
end

describe 'elasticsearch.yml.erb' do
  let :harness do
    TemplateHarness.new(
      'templates/etc/elasticsearch/elasticsearch.yml.erb'
    )
  end

  it 'renders normal hashes' do
    harness.set(
      '@data',
      'node.name' => 'test',
      'path.data' => '/mnt/test',
      'discovery.zen.ping.unicast.hosts' => %w[
        host1 host2
      ]
    )

    expect(YAML.safe_load(harness.run)).to eq(YAML.safe_load(%(
      discovery.zen.ping.unicast.hosts:
        - host1
        - host2
      node.name: test
      path.data: /mnt/test
      ).config))
  end

  it 'renders arrays of hashes correctly' do
    harness.set(
      '@data',
      'data' => [
        { 'key' => 'value0',
          'other_key' => 'othervalue0' },
        { 'key' => 'value1',
          'other_key' => 'othervalue1' }
      ]
    )

    expect(YAML.safe_load(harness.run)).to eq(YAML.safe_load(%(
      data:
      - key: value0
        other_key: othervalue0
      - key: value1
        other_key: othervalue1
      ).config))
  end

  it 'quotes IPv6 loopback addresses' do
    harness.set(
      '@data',
      'network.host' => ['::', '[::]']
    )

    expect(YAML.safe_load(harness.run)).to eq(YAML.safe_load(%(
      network.host:
        - "::"
        - "[::]"
      ).config))
  end

  it 'does not quote numeric values' do
    harness.set(
      '@data',
      'some.setting' => '10'
    )

    expect(YAML.safe_load(harness.run)).to eq(YAML.safe_load(%(
      some.setting: 10
    ).config))
  end
end
