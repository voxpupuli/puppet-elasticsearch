require 'spec_helper'

describe 'elasticsearch::template', :type => 'define' do

  let :facts do {
    :operatingsystem => 'CentOS',
    :kernel => 'Linux',
    :osfamily => 'RedHat'
  } end

  let(:title) { 'foo' }
  let(:pre_condition) { 'class {"elasticsearch": config => { "node" => {"name" => "test" }}}'}

  context "Add a template" do

    let :params do {
      :ensure => 'present',
      :file   => 'puppet:///path/to/foo.json',
    } end

    it { should contain_elasticsearch__template('foo') }
    it { should contain_file('/etc/elasticsearch/templates_import/elasticsearch-template-foo.json').with(:source => 'puppet:///path/to/foo.json', :notify => "Exec[insert_template_foo]", :require => "Exec[mkdir_templates_elasticsearch]") }
    it { should contain_exec('insert_template_foo').with(:command => "curl -sL -XPUT http://localhost:9200/_template/foo -d @/etc/elasticsearch/templates_import/elasticsearch-template-foo.json -o /dev/null -f", :unless => 'curl -s http://localhost:9200/_template/foo -f') }
  end

  context "Delete a template" do

    let :params do {
      :ensure => 'absent'
    } end

    it { should contain_elasticsearch__template('foo') }
    it { should_not contain_file('/etc/elasticsearch/templates_import/elasticsearch-template-foo.json').with(:source => 'puppet:///path/to/foo.json') }
    it { should_not contain_exec('insert_template_foo') }
    it { should contain_exec('delete_template_foo').with(:command => 'curl -s -XDELETE http://localhost:9200/_template/foo -f', :onlyif => 'curl -s -XGET http://localhost:9200/_template/foo -f' ) }
  end

  context "Add template with alternative host and port" do

    let :params do {
      :file => 'puppet:///path/to/foo.json',
      :host => 'otherhost',
      :port => '9201'
    } end

    it { should contain_elasticsearch__template('foo') }
    it { should contain_file('/etc/elasticsearch/templates_import/elasticsearch-template-foo.json').with(:source => 'puppet:///path/to/foo.json') }
    it { should contain_exec('insert_template_foo').with(:command => "curl -sL -XPUT http://otherhost:9201/_template/foo -d @/etc/elasticsearch/templates_import/elasticsearch-template-foo.json -o /dev/null -f", :unless => 'curl -s http://otherhost:9201/_template/foo -f') }
  end

end
