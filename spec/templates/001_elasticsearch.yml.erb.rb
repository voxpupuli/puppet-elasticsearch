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
end
