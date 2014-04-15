require 'spec_helper_acceptance'

describe "Service tests:" do

  cluster_name = SecureRandom.hex(10)

  case fact('osfamily')
    when 'RedHat'
      defaults_file = '/etc/sysconfig/elasticsearch'
      service_name  = 'elasticsearch'
      package_name  = 'elasticsearch'
      pid_file      = '/var/run/elasticsearch/elasticsearch.pid'
    when 'Debian'
      defaults_file = '/etc/default/elasticsearch'
      service_name  = 'elasticsearch'
      package_name  = 'elasticsearch'
      pid_file      = '/var/run/elasticsearch.pid'
    when 'Suse'
      defaults_file = '/etc/sysconfig/elasticsearch'
  end


  describe "Make sure we can manage the defaults file" do

    context "Change the defaults file" do
      it 'should run successfully' do
        pp = "class { 'elasticsearch': manage_repo => true, repo_version => '1.0', java_install => true, config => { 'node.name' => 'elasticsearch001', 'cluster.name' => '#{cluster_name}' }, init_defaults => { 'ES_USER' => 'root', 'ES_JAVA_OPTS' => '\"-server -XX:+UseTLAB -XX:+CMSClassUnloadingEnabled\"' } }"

        # Run it twice and test for idempotency
        apply_manifest(pp, :catch_failures => true)
        expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
      end
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

    context "Make sure we have ES_USER=root" do

      describe file(defaults_file) do
        its(:content) { should match /^ES_USER=root/ }
        its(:content) { should match /^ES_JAVA_OPTS="-server -XX:\+UseTLAB -XX:\+CMSClassUnloadingEnabled"/ }
        its(:content) { should_not match /^ES_USER=elasticsearch/ }
      end

    end

  end

end
