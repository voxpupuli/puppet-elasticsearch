require 'spec_helper_acceptance'

describe "elasticsearch class:" do

  case fact('osfamily')
  when 'RedHat'
    package_name = 'elasticsearch'
    service_name = 'elasticsearch'
  when 'Debian'
    package_name = 'elasticsearch'
    service_name = 'elasticsearch'
  end

  describe "default parameters" do

    it 'should run successfully' do
      pp = "class { 'elasticsearch': config => { 'node.name' => 'elasticsearch001' }, manage_repo => true, repo_version => '1.0', java_install => true }"

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end

    describe service(service_name) do
      it { should be_enabled }
      it { should be_running } 
    end

    describe package(package_name) do
      it { should be_installed }
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
