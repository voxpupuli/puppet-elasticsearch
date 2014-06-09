require 'spec_helper_acceptance'

describe "Elasticsearch class:" do

  cluster_name = SecureRandom.hex(10)

  case fact('osfamily')
    when 'RedHat'
      package_name   = 'elasticsearch'
      service_name_a = 'elasticsearch-es-01'
      service_name_b = 'elasticsearch-es-02'
      service_name_c = 'elasticsearch-es-03'
      pid_file_a     = '/var/run/elasticsearch/elasticsearch-es-01.pid'
      pid_file_b     = '/var/run/elasticsearch/elasticsearch-es-02.pid'
      pid_file_c     = '/var/run/elasticsearch/elasticsearch-es-03.pid'
      port_a         = '9200'
      port_b         = '9201'
      port_c         = '9202'
      url            = 'http://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.1.0.noarch.rpm'
      local          = '/tmp/elasticsearch-1.1.0.noarch.rpm'
      puppet         = 'elasticsearch-1.1.0.noarch.rpm'
    when 'Debian'
      package_name   = 'elasticsearch'
      service_name_a = 'elasticsearch-es-01'
      service_name_b = 'elasticsearch-es-02'
      service_name_c = 'elasticsearch-es-03'
      pid_file_a     = '/var/run/elasticsearch-es-01.pid'
      pid_file_b     = '/var/run/elasticsearch-es-02.pid'
      pid_file_c     = '/var/run/elasticsearch-es-03.pid'
      port_a         = '9200'
      port_b         = '9201'
      port_c         = '9202'
      url            = 'http://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.1.0.deb'
      local          = '/tmp/elasticsearch-1.1.0.deb'
      puppet         = 'elasticsearch-1.1.0.deb'
    when 'Suse'
      package_name   = 'elasticsearch'
      service_name_a = 'elasticsearch-es-01'
      service_name_b = 'elasticsearch-es-02'
      service_name_c = 'elasticsearch-es-03'
      pid_file_a     = '/var/run/elasticsearch/elasticsearch-es-01.pid'
      pid_file_b     = '/var/run/elasticsearch/elasticsearch-es-02.pid'
      pid_file_c     = '/var/run/elasticsearch/elasticsearch-es-03.pid'
      port_a         = '9200'
      port_b         = '9201'
      port_c         = '9202'
      url            = 'http://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.1.0.noarch.rpm'
      local          = '/tmp/elasticsearch-1.1.0.noarch.rpm'
      puppet         = 'elasticsearch-1.1.0.noarch.rpm'

  end

  shell("mkdir -p #{default['distmoduledir']}/another/files")
  shell("cp #{local} #{default['distmoduledir']}/another/files/#{puppet}")

  context "install via http resource" do

    it 'should run successfully' do
      pp = "class { 'elasticsearch': package_url => '#{url}', java_install => true, config => { 'node.name' => 'elasticsearch001', 'cluster.name' => '#{cluster_name}' } }
            elasticsearch::instance{ 'es-01': }
           "

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero

    end

    describe package(package_name) do
      it { should be_installed }
    end

    describe file(pid_file_a) do
      it { should be_file }
      its(:content) { should match /[0-9]+/ }
    end

    describe port(9200) do
      it {
        sleep 15
        should be_listening
      }
    end

    it 'make sure elasticsearch can serve requests' do
      curl_with_retries('check ES', default, 'http://localhost:9200/?pretty=true', 0)
    end

    describe service(service_name_a) do
      it { should be_enabled }
      it { should be_running }
    end

  end

  context "Clean" do
    it 'should run successfully' do
      pp = "class { 'elasticsearch': ensure => 'absent' }
            elasticsearch::instance{ 'es-01': ensure => 'absent' }
           "

      apply_manifest(pp, :catch_failures => true)
    end

    describe package(package_name) do
      it { should_not be_installed }
    end

    describe port(9200) do
      it {
        sleep 15
        should_not be_listening
      }
    end

    describe service(service_name_a) do
      it { should_not be_enabled }
      it { should_not be_running }
    end

  end

  context "Install via local file resource" do

    it 'should run successfully' do
      pp = "class { 'elasticsearch': package_url => 'file:#{local}', java_install => true, config => { 'node.name' => 'elasticsearch001', 'cluster.name' => '#{cluster_name}' } }
            elasticsearch::instance{ 'es-01': }
           "

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero

    end

    describe package(package_name) do
      it { should be_installed }
    end

    describe file(pid_file_a) do
      it { should be_file }
      its(:content) { should match /[0-9]+/ }
    end

    describe port(9200) do
      it {
        sleep 15
        should be_listening
      }
    end

    it 'make sure elasticsearch can serve requests' do
      curl_with_retries('check ES', default, 'http://localhost:9200/?pretty=true', 0)
    end

    describe service(service_name_a) do
      it { should be_enabled }
      it { should be_running }
    end

  end

  context "Clean" do
    it 'should run successfully' do
      pp = "class { 'elasticsearch': ensure => 'absent' }
            elasticsearch::instance{ 'es-01': ensure => 'absent' }
           "

      apply_manifest(pp, :catch_failures => true)
    end

    describe package(package_name) do
      it { should_not be_installed }
    end

    describe port(9200) do
      it {
        sleep 15
        should_not be_listening
      }
    end

    describe service(service_name_a) do
      it { should_not be_enabled }
      it { should_not be_running }
    end

  end

  context "Install via Puppet resource" do

    it 'should run successfully' do
      pp = "class { 'elasticsearch': package_url => 'puppet:///modules/another/#{puppet}', java_install => true, config => { 'node.name' => 'elasticsearch001', 'cluster.name' => '#{cluster_name}' } }
            elasticsearch::instance { 'es-01': }
           "

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero

    end

    describe package(package_name) do
      it { should be_installed }
    end

    describe file(pid_file_a) do
      it { should be_file }
      its(:content) { should match /[0-9]+/ }
    end

    it 'make sure elasticsearch can serve requests' do
      curl_with_retries('check ES', default, 'http://localhost:9200/?pretty=true', 0)
    end

    describe port(9200) do
      it {
        sleep 15
        should be_listening
      }
    end

    describe service(service_name_a) do
      it { should be_enabled }
      it { should be_running }
    end

  end

  context "Clean" do
    it 'should run successfully' do
      pp = "class { 'elasticsearch': ensure => 'absent' }
            elasticsearch::instance{ 'es-01': ensure => 'absent' }
           "

      apply_manifest(pp, :catch_failures => true)
    end

    describe package(package_name) do
      it { should_not be_installed }
    end

    describe port(9200) do
      it {
        sleep 15
        should_not be_listening
      }
    end

    describe service(service_name_a) do
      it { should_not be_enabled }
      it { should_not be_running }
    end

  end

end
