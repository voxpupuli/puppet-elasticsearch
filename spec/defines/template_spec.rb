require 'spec_helper'

describe 'elasticsearch::template', :type => 'define' do

  let(:title) { 'foo' }

  context "Add a template" do

    let :params do {
      :file => 'puppet:///path/to/foo.json',
    } end

    it { should contain_file('/etc/elasticsearch/templates/elasticsearch-template-foo.json').with(:source => 'puppet:///path/to/foo.json') }
    it { should contain_exec('curl -s -XPUT http://localhost:9200/_template/foo -d @/etc/elasticsearch/templates/elasticsearch-template-foo.json').with(:unless => 'test $(curl -s \'http://localhost:9200/_template/foo?pretty=true\' | wc -l) -gt 1') }
  end

  context "Delete a template" do

    let :params do {
      :delete => true
    } end

    it { should_not contain_file('/etc/elasticsearch/templates/elasticsearch-template-foo.json').with(:source => 'puppet:///path/to/foo.json') }
    it { should_not contain_exec('curl -s -XPUT http://localhost:9200/_template/foo -d @/etc/elasticsearch/templates/elasticsearch-template-foo.json').with(:unless => 'test $(curl -s \'http://localhost:9200/_template/foo?pretty=true\' | wc -l) -gt 1') }
    it { should contain_exec('curl -s -XDELETE http://localhost:9200/_template/foo').with(:before => nil ) }
  end

  context "Replace a template" do

    let :params do {
      :replace => true,
      :file => 'puppet:///path/to/foo.json'
    } end

    it { should contain_file('/etc/elasticsearch/templates/elasticsearch-template-foo.json').with(:source => 'puppet:///path/to/foo.json') }
    it { should contain_exec('curl -s -XPUT http://localhost:9200/_template/foo -d @/etc/elasticsearch/templates/elasticsearch-template-foo.json').with(:unless => 'test $(curl -s \'http://localhost:9200/_template/foo?pretty=true\' | wc -l) -gt 1') }
    it { should contain_exec('curl -s -XDELETE http://localhost:9200/_template/foo').with(:before => 'Exec[curl -s -XPUT http://localhost:9200/_template/foo -d @/etc/elasticsearch/templates/elasticsearch-template-foo.json]' ) }

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
    it { should contain_exec('curl -s -XPUT http://otherhost:9200/_template/foo -d @/etc/elasticsearch/templates/elasticsearch-template-foo.json').with(:unless => 'test $(curl -s \'http://otherhost:9200/_template/foo?pretty=true\' | wc -l) -gt 1') }
  end

end
