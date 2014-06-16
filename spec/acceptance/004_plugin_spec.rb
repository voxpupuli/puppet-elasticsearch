require 'spec_helper_acceptance'

describe "elasticsearch plugin define:" do

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


  describe "Install a plugin from official repository" do

    it 'should run successfully' do
      pp = "class { 'elasticsearch': config => { 'node.name' => 'elasticsearch001', 'cluster.name' => '#{cluster_name}' }, manage_repo => true, repo_version => '1.0', java_install => true }
            elasticsearch::instance { 'es-01': config => { 'node.name' => 'elasticsearch001', 'http.port' => '#{port_a}' } }
            elasticsearch::plugin{'mobz/elasticsearch-head': module_dir => 'head', instances => 'es-01' }
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

    describe port(9200) do
      it {
        sleep 15
        should be_listening
      }
    end

    it 'make sure the directory exists' do
      shell('ls /usr/share/elasticsearch/plugins/head/', {:acceptable_exit_codes => 0})
    end

    it 'make sure elasticsearch reports it as existing' do
      curl_with_retries('validated plugin as installed', default, 'http://localhost:9200/_nodes/?plugin | grep head', 0)
    end

  end
  describe "Install a plugin from custom git repo" do
    it 'should run successfully' do
      pending("Not implemented yet")
    end

    it 'make sure the directory exists' do
      pending("Not implemented yet")
    end

    it 'make sure elasticsearch reports it as existing' do
      pending("Not implemented yet")
    end

  end

  if fact('puppetversion') =~ /3\.[2-9]\./

    describe "Install a non existing plugin" do

      it 'should run successfully' do
        pp = "class { 'elasticsearch': config => { 'node.name' => 'elasticearch001', 'cluster.name' => '#{cluster_name}' }, manage_repo => true, repo_version => '1.0', java_install => true }
              elasticsearch::instance { 'es-01': config => { 'node.name' => 'elasticsearch001', 'http.port' => '#{port_a}' } }
              elasticsearch::plugin{'elasticsearch/non-existing': module_dir => 'non-existing', instances => 'es-01' }
        "
        #  Run it twice and test for idempotency
        apply_manifest(pp, :expect_failures => true)
      end

    end

  else
    # The exit codes have changes since Puppet 3.2x
    # Since beaker expectations are based on the most recent puppet code All runs on previous versions fails.
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

    describe package(package_name) do
      it { should_not be_installed }
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


  describe "install plugin while running ES under user 'root'" do

    it 'should run successfully' do
      pp = "class { 'elasticsearch': config => { 'node.name' => 'elasticsearch001', 'cluster.name' => '#{cluster_name}' }, manage_repo => true, repo_version => '1.0', java_install => true, elasticsearch_user => 'root', elasticsearch_group => 'root' }
            elasticsearch::instance { 'es-01': config => { 'node.name' => 'elasticsearch001', 'http.port' => '#{port_a}' } }
            elasticsearch::plugin{'lmenezes/elasticsearch-kopf': module_dir => 'kopf', instances => 'es-01' }
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

    describe port(9200) do
      it {
        sleep 15
        should be_listening
      }
    end

    it 'make sure the directory exists' do
      shell('ls /usr/share/elasticsearch/plugins/kopf/', {:acceptable_exit_codes => 0})
    end

    it 'make sure elasticsearch reports it as existing' do
      curl_with_retries('validated plugin as installed', default, 'http://localhost:9200/_nodes/?plugin | grep kopf', 0)
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

    describe package(package_name) do
      it { should_not be_installed }
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
