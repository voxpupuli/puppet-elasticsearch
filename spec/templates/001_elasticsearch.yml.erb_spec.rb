require 'spec_helper'

class String
  def config
    "### MANAGED BY PUPPET ###\n---#{unindent}"
  end

  def unindent
    gsub(/^#{scan(/^\s*/).min_by{|l|l.length}}/, "")
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
      '@data', {
        'node.name' => 'test',
        'path' => { 'data' => '/mnt/test' },
        'discovery.zen.ping.unicast.hosts' => [
          'host1', 'host2'
        ]
      }
    )

    expect(harness.run).to eq(%q{
      discovery:
        zen:
          ping:
            unicast:
              hosts:
                - host1
                - host2
      node:
        name: test
      path:
        data: /mnt/test
      }.config)
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
  end

  it 'should concatenate arrays' do
    harness.set(
      '@data', {
        'data.path' => ['/mnt/sda1'],
        'data' => { 'path' => ['/mnt/sdb1'] }
      }
    )

    expect(harness.run).to eq(%q{
      data:
        path:
          - /mnt/sda1
          - /mnt/sdb1
      }.config)
  end

  it 'should qualify conflicting hash keys' do
    harness.set(
      '@data', {
        'shield.http.ssl' => 'true',
        'shield.http.ssl.client.auth' => 'optional'
      }
    )

    expect(harness.run).to eq(%q{
      shield:
        http:
          ssl: "true"
          ssl.client:
            auth: optional
      }.config)
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
          { 'key' => 'some value 0',
            'other_key' => 'some other value 0' },
          { 'key' => 'some value 1',
            'other_key' => 'some other value 1' },
        ]
      }
    )

    expect(harness.run).to eq(%q{
      data:
        - key: "some value 0"
          other_key: "some other value 0"
        - key: "some value 1"
          other_key: "some other value 1"
      discovery:
        zen:
          ping:
            unicast:
              hosts:
                - host1
                - host2
      node:
        name: test
      path:
        data: /mnt/test
      }.config)
  end
end
