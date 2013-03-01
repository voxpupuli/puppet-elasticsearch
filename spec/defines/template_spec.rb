require 'spec_helper'

describe 'elasticsearch::template', :type => 'define' do

  let(:title) { 'foo' }

  context "Add a template" do

    let :params do {
      :file => 'puppet:///path/to/foo.json',
    } end

    it { should contain_file('/etc/elasticsearch/templates/elasticsearch-template-foo.json').with(:source => 'puppet:///path/to/foo.json') }
    it { should contain_exec('insert_template').with(:command => 'curl -s -XPUT http://localhost:9200/_template/foo -d @/etc/elasticsearch/templates/elasticsearch-template-foo.json', :unless => 'test $(curl -s \'http://localhost:9200/_template/foo?pretty=true\' | wc -l) -gt 1') }
  end

  context "Delete a template" do

    let :params do {
      :delete => true
    } end

    it { should_not contain_file('/etc/elasticsearch/templates/elasticsearch-template-foo.json').with(:source => 'puppet:///path/to/foo.json') }
    it { should_not contain_exec('insert_template') }
    it { should contain_exec('delete_template').with(:command => 'curl -s -XDELETE http://localhost:9200/_template/foo', :before => nil ) }
  end

  context "Replace a template" do

    let :params do {
      :replace => true,
      :file => 'puppet:///path/to/foo.json'
    } end

    it { should contain_file('/etc/elasticsearch/templates/elasticsearch-template-foo.json').with(:source => 'puppet:///path/to/foo.json') }
    it { should contain_exec('insert_template').with(:command => 'curl -s -XPUT http://localhost:9200/_template/foo -d @/etc/elasticsearch/templates/elasticsearch-template-foo.json', :unless => 'test $(curl -s \'http://localhost:9200/_template/foo?pretty=true\' | wc -l) -gt 1') }
    it { should contain_exec('delete_template').with(:command => 'curl -s -XDELETE http://localhost:9200/_template/foo', :before => 'Exec[insert_template]' ) }

  end

  context "Try replace and delete at the same time" do

    let :params do {
      :replace => true,
      :delete => true,
      :file => 'puppet:///path/to/foo.json'
    } end

    it { expect { should raise_error(Puppet::Error) } }

  end

  context "Add template with alternative host" do

    let :params do {
      :file => 'puppet:///path/to/foo.json',
      :host => 'otherhost'
    } end

    it { should contain_file('/etc/elasticsearch/templates/elasticsearch-template-foo.json').with(:source => 'puppet:///path/to/foo.json') }
    it { should contain_exec('insert_template').with(:command => 'curl -s -XPUT http://otherhost:9200/_template/foo -d @/etc/elasticsearch/templates/elasticsearch-template-foo.json', :unless => 'test $(curl -s \'http://otherhost:9200/_template/foo?pretty=true\' | wc -l) -gt 1') }
  end

end
