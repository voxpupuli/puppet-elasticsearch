require 'spec_helper_acceptance'

describe "elasticsearch class:" do

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

  end

  describe "single instance" do

    it 'should run successfully' do
      pp = "class { 'elasticsearch': config => { 'cluster.name' => '#{cluster_name}'}, manage_repo => true, repo_version => '1.0', java_install => true }
            elasticsearch::instance { 'es-01': config => { 'node.name' => 'elasticsearch001', 'http.port' => '#{port_a}' } }
           "

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end


    describe service(service_name_a) do
      it { should be_enabled }
      it { should be_running }
    end

    describe package(package_name) do
      it { should be_installed }
    end

    describe file(pid_file_a) do
      it { should be_file }
      its(:content) { should match /[0-9]+/ }
    end

    describe port(port_a) do
      it {
        sleep 15
        should be_listening
      }
    end

    describe "Elasticsearch serves requests on" do
      it {
        curl_with_retries("check ES on #{port_a}", default, "http://localhost:#{port_a}/?pretty=true", 0)
      }
    end

    describe file('/etc/elasticsearch/es-01/elasticsearch.yml') do
      it { should be_file }
      it { should contain 'name: elasticsearch001' }
    end

    describe file('/etc/elasticsearch/templates_import') do
      it { should be_directory }
    end


  end


  describe "multiple instances" do

    it 'should run successfully' do
      pp = "class { 'elasticsearch': config => { 'cluster.name' => '#{cluster_name}'}, manage_repo => true, repo_version => '1.0', java_install => true }
            elasticsearch::instance { 'es-01': config => { 'node.name' => 'elasticsearch001', 'http.port' => '#{port_a}' } }
            elasticsearch::instance { 'es-02': config => { 'node.name' => 'elasticsearch002', 'http.port' => '#{port_b}' } }
           "

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end


    describe service(service_name_a) do
      it { should be_enabled }
      it { should be_running }
    end

    describe service(service_name_b) do
      it { should be_enabled }
      it { should be_running }
    end

    describe package(package_name) do
      it { should be_installed }
    end

    describe file(pid_file_a) do
      it { should be_file }
      its(:content) { should match /[0-9]+/ }
    end

    describe file(pid_file_b) do
      it { should be_file }
      its(:content) { should match /[0-9]+/ }
    end

    describe port(port_a) do
      it {
        should be_listening
      }
    end

    describe port(port_b) do
      it {
        sleep 10
        should be_listening
      }
    end

    describe "make sure elasticsearch can serve requests #{port_a}" do
      it {
        curl_with_retries("check ES on #{port_a}", default, "http://localhost:#{port_a}/?pretty=true", 0)
      }
    end

    describe "make sure elasticsearch can serve requests #{port_b}" do
      it {
        curl_with_retries("check ES on #{port_b}", default, "http://localhost:#{port_b}/?pretty=true", 0)
      }
    end

    describe file('/etc/elasticsearch/es-01/elasticsearch.yml') do
      it { should be_file }
      it { should contain 'name: elasticsearch001' }
    end

    describe file('/etc/elasticsearch/es-02/elasticsearch.yml') do
      it { should be_file }
      it { should contain 'name: elasticsearch002' }
    end

  end


  describe "module removal" do

    it 'should run successfully' do
      pp = "class { 'elasticsearch': ensure => 'absent' }
            elasticsearch::instance{ 'es-01': ensure => 'absent' }
            elasticsearch::instance{ 'es-02': ensure => 'absent' }
           "

      apply_manifest(pp, :catch_failures => true)
    end

    describe file('/etc/elasticsearch/es-01') do
      it { should_not be_directory }
    end

    describe file('/etc/elasticsearch/es-02') do
      it { should_not be_directory }
    end

    describe file('/etc/elasticsearch/es-03') do
      it { should_not be_directory }
    end

    describe port(port_a) do
      it {
        should_not be_listening
      }
    end

    describe port(port_b) do
      it {
        should_not be_listening
      }
    end

    describe port(port_c) do
      it {
        should_not be_listening
      }
    end

    describe service(service_name_a) do
      it { should_not be_enabled }
      it { should_not be_running }
    end

    describe service(service_name_b) do
      it { should_not be_enabled }
      it { should_not be_running }
    end

    describe service(service_name_c) do
      it { should_not be_enabled }
      it { should_not be_running }
    end

  end

end
