require 'spec_helper_acceptance'

describe "Data dir settings" do

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

  datadir_1 = '/var/lib/elasticsearch-data/1/'
  datadir_2 = '/var/lib/elasticsearch-data/2/'
  datadir_3 = '/var/lib/elasticsearch-data/3/'


  describe "Default data dir" do

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
      it { should contain "/usr/share/elasticsearch/data/es-01" }
    end

     describe "Elasticsearch config has the data path" do
      it {
        curl_with_retries("check data path on #{port_a}", default, "http://localhost:#{port_a}/_nodes?pretty=true | grep /usr/share/elasticsearch/data/es-01", 0)
      }

    end

    describe file('/usr/share/elasticsearch/data/es-01') do
      it { should be_directory }
    end

  end


  describe "Single data dir from main class" do

    it 'should run successfully' do
      pp = "class { 'elasticsearch': config => { 'cluster.name' => '#{cluster_name}'}, manage_repo => true, repo_version => '1.0', java_install => true, datadir => '/var/lib/elasticsearch-data' }
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
      it { should contain '/var/lib/elasticsearch-data/es-01' }
    end

     describe "Elasticsearch config has the data path" do
      it {
        curl_with_retries("check data path on #{port_a}", default, "http://localhost:#{port_a}/_nodes?pretty=true | grep /var/lib/elasticsearch-data/es-01", 0)
      }

    end

    describe file('/var/lib/elasticsearch-data/es-01') do
      it { should be_directory }
    end

  end

  describe "module removal" do

    it 'should run successfully' do
      pp = "class { 'elasticsearch': ensure => 'absent' }
            elasticsearch::instance{ 'es-01': ensure => 'absent' }
           "

      apply_manifest(pp, :catch_failures => true)
    end

    describe file('/etc/elasticsearch/es-01') do
      it { should_not be_directory }
    end

    describe port(port_a) do
      it {
        should_not be_listening
      }
    end

    describe service(service_name_a) do
      it { should_not be_enabled }
      it { should_not be_running }
    end

  end

  describe "Single data dir from instance config" do

    it 'should run successfully' do
      pp = "class { 'elasticsearch': config => { 'cluster.name' => '#{cluster_name}'}, manage_repo => true, repo_version => '1.0', java_install => true }
            elasticsearch::instance { 'es-01': config => { 'node.name' => 'elasticsearch001', 'http.port' => '#{port_a}'}, datadir => '#{datadir_1}' }
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
      it { should contain "#{datadir_1}" }
    end

     describe "Elasticsearch config has the data path" do
      it {
        curl_with_retries("check data path on #{port_a}", default, "http://localhost:#{port_a}/_nodes?pretty=true | grep #{datadir_1}", 0)
      }
    end

    describe file(datadir_1) do
      it { should be_directory }
    end

  end

  describe "module removal" do

    it 'should run successfully' do
      pp = "class { 'elasticsearch': ensure => 'absent' }
            elasticsearch::instance{ 'es-01': ensure => 'absent' }
           "

      apply_manifest(pp, :catch_failures => true)
    end

    describe file('/etc/elasticsearch/es-01') do
      it { should_not be_directory }
    end

    describe port(port_a) do
      it {
        should_not be_listening
      }
    end

    describe service(service_name_a) do
      it { should_not be_enabled }
      it { should_not be_running }
    end

  end

  describe "multiple data dir's from main class" do

    it 'should run successfully' do
      pp = "class { 'elasticsearch': config => { 'cluster.name' => '#{cluster_name}'}, manage_repo => true, repo_version => '1.0', java_install => true, datadir => [ '/var/lib/elasticsearch/01', '/var/lib/elasticsearch/02'] }
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
      it { should contain '/var/lib/elasticsearch/01/es-01' }
      it { should contain '/var/lib/elasticsearch/02/es-01' }
    end

     describe "Elasticsearch config has the data path" do
      it {
        curl_with_retries("check data path on #{port_a}", default, "http://localhost:#{port_a}/_nodes?pretty=true | grep /var/lib/elasticsearch/01/es-01", 0)
      }
      it {
        curl_with_retries("check data path on #{port_a}", default, "http://localhost:#{port_a}/_nodes?pretty=true | grep /var/lib/elasticsearch/02/es-01", 0)
      }

    end

    describe file('/var/lib/elasticsearch/01/es-01') do
      it { should be_directory }
    end

    describe file('/var/lib/elasticsearch/02/es-01') do
      it { should be_directory }
    end

  end

  describe "module removal" do

    it 'should run successfully' do
      pp = "class { 'elasticsearch': ensure => 'absent' }
            elasticsearch::instance{ 'es-01': ensure => 'absent' }
           "

      apply_manifest(pp, :catch_failures => true)
    end

    describe file('/etc/elasticsearch/es-01') do
      it { should_not be_directory }
    end

    describe port(port_a) do
      it {
        should_not be_listening
      }
    end

    describe service(service_name_a) do
      it { should_not be_enabled }
      it { should_not be_running }
    end

  end


  describe "multiple data dir's from instance config" do

    it 'should run successfully' do
      pp = "class { 'elasticsearch': config => { 'cluster.name' => '#{cluster_name}'}, manage_repo => true, repo_version => '1.0', java_install => true }
            elasticsearch::instance { 'es-01': config => { 'node.name' => 'elasticsearch001', 'http.port' => '#{port_a}' }, datadir => [ '#{datadir_2}', '#{datadir_3}'] }
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
      it { should contain "#{datadir_2}" }
      it { should contain "#{datadir_3}" }
    end

     describe "Elasticsearch config has the data path" do
      it {
        curl_with_retries("check data path on #{port_a}", default, "http://localhost:#{port_a}/_nodes?pretty=true | grep #{datadir_2}", 0)
      }
      it {
        curl_with_retries("check data path on #{port_a}", default, "http://localhost:#{port_a}/_nodes?pretty=true | grep #{datadir_3}", 0)
      }

    end

    describe file(datadir_1) do
      it { should be_directory }
    end

    describe file(datadir_2) do
      it { should be_directory }
    end

  end

  describe "module removal" do

    it 'should run successfully' do
      pp = "class { 'elasticsearch': ensure => 'absent' }
            elasticsearch::instance{ 'es-01': ensure => 'absent' }
           "

      apply_manifest(pp, :catch_failures => true)
    end

    describe file('/etc/elasticsearch/es-01') do
      it { should_not be_directory }
    end

    describe port(port_a) do
      it {
        should_not be_listening
      }
    end

    describe service(service_name_a) do
      it { should_not be_enabled }
      it { should_not be_running }
    end

  end

end
