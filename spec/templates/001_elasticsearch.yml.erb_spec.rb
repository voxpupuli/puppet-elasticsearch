require 'spec_helper'
require 'yaml'

class String
  def config
    "### MANAGED BY PUPPET ###\n---#{unindent}"
  end

  def unindent
    gsub(/^#{scan(/^\s*/).min_by{|l|l.length}}/, "")
  end
end

# Puppet 4 YAML implementation doesn't indent array elements
if Puppet.version >= '4.0.0'
  indent = ''
else
  indent = '  '
end

describe 'elasticsearch.yml.erb' do

  let :harness do
    TemplateHarness.new(
      'templates/etc/elasticsearch/elasticsearch.yml.erb'
    )
  end

  it 'should render normal hashes' do
    harness.set(
      '@data', {
        'node.name' => 'test',
        'path' => { 'data' => '/mnt/test' },
        'discovery.zen.ping.unicast.hosts' => [
          'host1', 'host2'
        ]
      }
    )

    expect(harness.run).to eq(%Q{
      discovery:
        zen:
          ping:
            unicast:
              hosts:
              #{indent}- host1
              #{indent}- host2
      node:
        name: test
      path:
        data: /mnt/test
      }.config)

    # Check for a valid YAML
    expect{ YAML.load(harness.run) }.to_not raise_error
  end

  it 'should merge hashes' do
    harness.set(
      '@data', {
        'node.name' => 'test',
        'node.rack' => 'r1'
      }
    )

    expect(harness.run).to eq(%q{
      node:
        name: test
        rack: r1
      }.config)

    expect{ YAML.load(harness.run) }.to_not raise_error
  end

  it 'should concatenate arrays' do
    harness.set(
      '@data', {
        'data.path' => ['/mnt/sda1'],
        'data' => { 'path' => ['/mnt/sdb1'] }
      }
    )

    expect(harness.run).to eq(%Q{
      data:
        path:
        #{indent}- /mnt/sda1
        #{indent}- /mnt/sdb1
      }.config)

    expect{ YAML.load(harness.run) }.to_not raise_error
  end

  it 'should qualify conflicting hash keys' do
    harness.set(
      '@data', {
        'shield.http.ssl' => true,
        'shield.http.ssl.client.auth' => 'optional'
      }
    )

    expect(harness.run).to eq(%q{
      shield:
        http:
          ssl: true
          ssl.client:
            auth: optional
      }.config)

    expect{ YAML.load(harness.run) }.to_not raise_error
  end

  it 'should render correct array of hashes' do
    harness.set(
      '@data', {
        'node.name' => 'test',
        'path' => { 'data' => '/mnt/test' },
        'discovery.zen.ping.unicast.hosts' => [
          'host1', 'host2'
        ],
        'data' => [
          { 'key' => 'value0',
            'other_key' => 'othervalue0' },
          { 'key' => 'value1',
            'other_key' => 'othervalue1' }
        ]
      }
    )

    expect(harness.run).to eq(%Q{
      data:
      #{indent}- key: value0
      #{indent}  other_key: othervalue0
      #{indent}- key: value1
      #{indent}  other_key: othervalue1
      discovery:
        zen:
          ping:
            unicast:
              hosts:
              #{indent}- host1
              #{indent}- host2
      node:
        name: test
      path:
        data: /mnt/test
      }.config)

    expect{ YAML.load(harness.run) }.to_not raise_error
  end

  it 'should handle value with spaces' do
    harness.set(
      '@data', {
        'key' => 'value with spaces'
      }
    )

    # Handle different YAML implementations in Puppet 3 and 4
    if Puppet.version >= '4.0.0'
      expect(harness.run).to eq(%q{
        key: value with spaces
        }.config)
    else
      expect(harness.run).to eq(%q{
        key: "value with spaces"
        }.config)
    end

    expect{ YAML.load(harness.run) }.to_not raise_error
  end

  it 'should respect boolean value data type' do
    harness.set(
      '@data', {
        'cloud' => { 'node' =>
          { 'auto_attributes' => true } },
        'shield.http.ssl' => 'true',
        'shield.http.ssl.client.auth' => 'optional'
      }
    )

    # Handle different YAML implementations in Puppet 3 and 4
    if Puppet.version >= '4.0.0'
      expect(harness.run).to eq(%q{
        cloud:
          node:
            auto_attributes: true
        shield:
          http:
            ssl: 'true'
            ssl.client:
              auth: optional
        }.config)
    else
      expect(harness.run).to eq(%q{
        cloud:
          node:
            auto_attributes: true
        shield:
          http:
            ssl: "true"
            ssl.client:
              auth: optional
        }.config)
    end

    expect{ YAML.load(harness.run) }.to_not raise_error
  end
end
