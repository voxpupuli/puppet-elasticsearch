require 'spec_helper_acceptance'

describe "elasticsearch class:" do

  cluster_name = SecureRandom.hex(10)

  case fact('osfamily')
    when 'RedHat'
      package_name = 'elasticsearch'
      service_name = 'elasticsearch'
      pid_file     = '/var/run/elasticsearch/elasticsearch.pid'
    when 'Debian'
      package_name = 'elasticsearch'
      service_name = 'elasticsearch'
      pid_file     = '/var/run/elasticsearch.pid'
    when 'Suse'
      package_name = 'elasticsearch'
      service_name = 'elasticsearch'
  end

  describe "default parameters" do

    it 'should run successfully' do
      pp = "class { 'elasticsearch': config => { 'node.name' => 'elasticsearch001', 'cluster.name' => '#{cluster_name}'}, manage_repo => true, repo_version => '1.0', java_install => true }"

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

    describe file('/etc/elasticsearch/elasticsearch.yml') do
      it { should be_file }
      it { should contain 'name: elasticsearch001' }
    end

    describe file('/etc/elasticsearch/templates_import') do
      it { should be_directory }
    end

  end

end
