require 'spec_helper'
require 'yaml'

class String
  def config
    "### MANAGED BY PUPPET ###\n---#{unindent}"
  end

  def unindent
    gsub(/^#{scan(/^\s*/).min_by(&:length)}/, '')
  end
end

describe 'elasticsearch.yml.erb' do
  let :harness do
    TemplateHarness.new(
      'templates/etc/elasticsearch/elasticsearch.yml.erb'
    )
  end

  it 'should render normal hashes' do
    harness.set(
      '@data',
      'node.name' => 'test',
      'path.data' => '/mnt/test',
      'discovery.zen.ping.unicast.hosts' => %w[
        host1 host2
      ]
    )

    expect(YAML.load(harness.run)).to eq(YAML.load(%(
      discovery.zen.ping.unicast.hosts:
        - host1
        - host2
      node.name: test
      path.data: /mnt/test
      ).config))
  end

  it 'should render arrays of hashes correctly' do
    harness.set(
      '@data',
      'data' => [
        { 'key' => 'value0',
          'other_key' => 'othervalue0' },
        { 'key' => 'value1',
          'other_key' => 'othervalue1' }
      ]
    )

    expect(YAML.load(harness.run)).to eq(YAML.load(%(
      data:
      - key: value0
        other_key: othervalue0
      - key: value1
        other_key: othervalue1
      ).config))
  end

  it 'should quote IPv6 loopback addresses' do
    harness.set(
      '@data',
      'network.host' => ['::', '[::]']
    )

    expect(YAML.load(harness.run)).to eq(YAML.load(%(
      network.host:
        - "::"
        - "[::]"
      ).config))
  end

  it 'should not quote numeric values' do
    harness.set(
      '@data',
      'some.setting' => '10'
    )

    expect(YAML.load(harness.run)).to eq(YAML.load(%(
      some.setting: 10
    ).config))
  end
end
