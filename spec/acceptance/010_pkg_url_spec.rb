require 'spec_helper_acceptance'

if fact('osfamily') != 'Suse'

describe "Elasticsearch class:" do

  cluster_name = SecureRandom.hex(10)

  case fact('osfamily')
  when 'RedHat'
    package_name = 'elasticsearch'
    service_name = 'elasticsearch'
    url          = 'http://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.1.0.noarch.rpm'
    local        = '/tmp/elasticsearch-1.1.0.noarch.rpm'
    puppet       = 'elasticsearch-1.1.0.noarch.rpm'
    pid_file     = '/var/run/elasticsearch/elasticsearch.pid'
  when 'Debian'
    package_name = 'elasticsearch'
    service_name = 'elasticsearch'
    url          = 'http://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.1.0.deb'
    local        = '/tmp/elasticsearch-1.1.0.deb'
    puppet       = 'elasticsearch-1.1.0.deb'
    pid_file     = '/var/run/elasticsearch.pid'
  end

  shell("mkdir -p #{default['distmoduledir']}/another/files")
  shell("cp #{local} #{default['distmoduledir']}/another/files/#{puppet}")

  context "install via http resource" do

    it 'should run successfully' do
      pp = "class { 'elasticsearch': package_url => '#{url}', java_install => true, config => { 'node.name' => 'elasticsearch001', 'cluster.name' => '#{cluster_name}' } }"

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero

    end

    describe package(package_name) do
      it { should be_installed }
    end

    describe file(pid_file) do
      it { should be_file }
      its(:content) { should match /[0-9]+/ }
    end

    describe port(9200) do
      it {
        sleep 10
        should be_listening
      }
    end

    describe service(service_name) do
      it { should be_enabled }
      it { should be_running }
    end

  end

  context "Clean" do
    it 'should run successfully' do
      apply_manifest("class { 'elasticsearch': ensure => absent }", :catch_failures => true)
    end

    describe package(package_name) do
      it { should_not be_installed }
    end

    describe port(9200) do
      it {
        sleep 10
        should_not be_listening
      }
    end

    describe service(service_name) do
      it { should_not be_enabled }
      it { should_not be_running }
    end

  end

  context "Install via local file resource" do

    it 'should run successfully' do
      pp = "class { 'elasticsearch': package_url => 'file:#{local}', java_install => true, config => { 'node.name' => 'elasticsearch001', 'cluster.name' => '#{cluster_name}' } }"

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero

    end

    describe package(package_name) do
      it { should be_installed }
    end

    describe file(pid_file) do
      it { should be_file }
      its(:content) { should match /[0-9]+/ }
    end

    describe port(9200) do
      it {
        sleep 10
        should be_listening
      }
    end

    describe service(service_name) do
      it { should be_enabled }
      it { should be_running }
    end

  end

  context "Clean" do
    it 'should run successfully' do
      apply_manifest("class { 'elasticsearch': ensure => absent }", :catch_failures => true)
    end

    describe package(package_name) do
      it { should_not be_installed }
    end

    describe port(9200) do
      it {
        sleep 10
        should_not be_listening
      }
    end

    describe service(service_name) do
      it { should_not be_enabled }
      it { should_not be_running }
    end

  end

  context "Install via Puppet resource" do

    it 'should run successfully' do
      pp = "class { 'elasticsearch': package_url => 'puppet:///modules/another/#{puppet}', java_install => true, config => { 'node.name' => 'elasticsearch001', 'cluster.name' => '#{cluster_name}' } }"

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      sleep 5
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero

    end

    describe package(package_name) do
      it { should be_installed }
    end

    describe file(pid_file) do
      it { should be_file }
      its(:content) { should match /[0-9]+/ }
    end

    describe port(9200) do
      it {
        sleep 10
        should be_listening
      }
    end

    describe service(service_name) do
      it { should be_enabled }
      it { should be_running }
    end

  end

  context "Clean" do
    it 'should run successfully' do
      apply_manifest("class { 'elasticsearch': ensure => absent }", :catch_failures => true)
    end

    describe package(package_name) do
      it { should_not be_installed }
    end

    describe port(9200) do
      it {
        sleep 5
        should_not be_listening
      }
    end

    describe service(service_name) do
      it { should_not be_enabled }
      it { should_not be_running }
    end

  end

  end

end
