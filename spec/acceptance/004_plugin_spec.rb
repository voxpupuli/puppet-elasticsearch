require 'spec_helper_acceptance'

describe "elasticsearch plugin define:" do

  cluster_name = SecureRandom.hex(10)

  case fact('osfamily')
    when 'RedHat'
      service_name  = 'elasticsearch'
      package_name  = 'elasticsearch'
      pid_file      = '/var/run/elasticsearch/elasticsearch.pid'
    when 'Debian'
      service_name  = 'elasticsearch'
      package_name  = 'elasticsearch'
      pid_file      = '/var/run/elasticsearch.pid'
  end


  describe "Install a plugin from official repository" do

    it 'should run successfully' do
			pp = "class { 'elasticsearch': config => { 'node.name' => 'elasticsearch001', 'cluster.name' => '#{cluster_name}' }, manage_repo => true, repo_version => '1.0', java_install => true }
            elasticsearch::plugin{'mobz/elasticsearch-head': module_dir => 'head' }
           "

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end

    if fact('osfamily') != 'Suse'
      describe service(service_name) do
        it { should be_enabled }
        it { should be_running } 
      end

      describe package(package_name) do
        it { should be_installed }
      end

      describe file(pid_file) do
        it { should be_file }
        its(:content) { should match /[0-9]+/ }
      end
    end

    describe port(9200) do
      it {
        sleep 10
        should be_listening
      }
    end

    it 'make sure the directory exists' do
      shell('ls /usr/share/elasticsearch/plugins/head/', {:acceptable_exit_codes => 0})
    end

    it 'make sure elasticsearch reports it as existing' do
      sleep 10
      shell("/usr/bin/curl http://localhost:9200/_nodes/?plugin | grep head", {:acceptable_exit_codes => 0})
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
              elasticsearch::plugin{'elasticsearch/non-existing': module_dir => 'non-existing' }
        "
        #  Run it twice and test for idempotency
        apply_manifest(pp, :expect_failures => true)
      end

    end

  else
    # The exit codes have changes since Puppet 3.2x
    # Since beaker expectations are based on the most recent puppet code All runs on previous versions fails.
  end


  describe "install plugin while running ES under user 'root'" do

    it 'should run successfully' do
      pp = "class { 'elasticsearch': config => { 'node.name' => 'elasticsearch001', 'cluster.name' => '#{cluster_name}' }, manage_repo => true, repo_version => '1.0', java_install => true, elasticsearch_user => 'root', elasticsearch_group => 'root' }
            elasticsearch::plugin{'lmenezes/elasticsearch-kopf': module_dir => 'kopf' }
      "

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end

    if fact('osfamily') != 'Suse'
      describe service(service_name) do
        it { should be_enabled }
        it { should be_running } 
      end

      describe package(package_name) do
        it { should be_installed }
      end

      describe file(pid_file) do
        it { should be_file }
        its(:content) { should match /[0-9]+/ }
      end
    end

    describe port(9200) do
      it {
        sleep 10
        should be_listening
      }
    end

    it 'make sure the directory exists' do
      shell('ls /usr/share/elasticsearch/plugins/kopf/', {:acceptable_exit_codes => 0})
    end

    it 'make sure elasticsearch reports it as existing' do
      sleep 10
      shell("/usr/bin/curl http://localhost:9200/_nodes/?plugin | grep kopf", {:acceptable_exit_codes => 0})
    end

  end

end
