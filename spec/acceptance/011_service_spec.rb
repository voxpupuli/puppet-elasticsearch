require 'spec_helper_acceptance'

describe "Service tests:" do

  cluster_name = SecureRandom.hex(10)

  case fact('osfamily')
    when 'RedHat'
      package_name    = 'elasticsearch'
      service_name_a  = 'elasticsearch-es-01'
      service_name_b  = 'elasticsearch-es-02'
      service_name_c  = 'elasticsearch-es-03'
      pid_file_a      = '/var/run/elasticsearch/elasticsearch-es-01.pid'
      pid_file_b      = '/var/run/elasticsearch/elasticsearch-es-02.pid'
      pid_file_c      = '/var/run/elasticsearch/elasticsearch-es-03.pid'
      port_a          = '9200'
      port_b          = '9201'
      port_c          = '9202'
      defaults_file_a = '/etc/sysconfig/elasticsearch-es-01'
      defaults_file_b = '/etc/sysconfig/elasticsearch-es-02'
      defaults_file_c = '/etc/sysconfig/elasticsearch-es-03'
    when 'Debian'
      package_name    = 'elasticsearch'
      service_name_a  = 'elasticsearch-es-01'
      service_name_b  = 'elasticsearch-es-02'
      service_name_c  = 'elasticsearch-es-03'
      pid_file_a      = '/var/run/elasticsearch-es-01.pid'
      pid_file_b      = '/var/run/elasticsearch-es-02.pid'
      pid_file_c      = '/var/run/elasticsearch-es-03.pid'
      port_a          = '9200'
      port_b          = '9201'
      port_c          = '9202'
      defaults_file_a = '/etc/default/elasticsearch-es-01'
      defaults_file_b = '/etc/default/elasticsearch-es-02'
      defaults_file_c = '/etc/default/elasticsearch-es-03'
    when 'Suse'
      package_name    = 'elasticsearch'
      service_name_a  = 'elasticsearch-es-01'
      service_name_b  = 'elasticsearch-es-02'
      service_name_c  = 'elasticsearch-es-03'
      pid_file_a      = '/var/run/elasticsearch/elasticsearch-es-01.pid'
      pid_file_b      = '/var/run/elasticsearch/elasticsearch-es-02.pid'
      pid_file_c      = '/var/run/elasticsearch/elasticsearch-es-03.pid'
      port_a          = '9200'
      port_b          = '9201'
      port_c          = '9202'
      defaults_file_a = '/etc/sysconfig/elasticsearch-es-01'
      defaults_file_b = '/etc/sysconfig/elasticsearch-es-02'
      defaults_file_c = '/etc/sysconfig/elasticsearch-es-03'
  end

  describe "Make sure we can manage the defaults file" do

    context "Change the defaults file" do
      it 'should run successfully' do
        pp = "class { 'elasticsearch': manage_repo => true, repo_version => '1.0', java_install => true, config => { 'cluster.name' => '#{cluster_name}' }, init_defaults => { 'ES_USER' => 'root', 'ES_JAVA_OPTS' => '\"-server -XX:+UseTLAB -XX:+CMSClassUnloadingEnabled\"' } }
              elasticsearch::instance { 'es-01': config => { 'node.name' => 'elasticsearch001' } }
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

      describe file('/etc/elasticsearch/es-01/elasticsearch.yml') do
        it { should be_file }
        it { should contain 'name: elasticsearch001' }
      end

      describe 'make sure elasticsearch can serve requests' do
        it {
          curl_with_retries('check ES', default, 'http://localhost:9200/?pretty=true', 0)
        }
      end

      context "Make sure we have ES_USER=root" do

        describe file(defaults_file_a) do
          its(:content) { should match /^ES_USER=root/ }
          its(:content) { should match /^ES_JAVA_OPTS="-server -XX:\+UseTLAB -XX:\+CMSClassUnloadingEnabled"/ }
          its(:content) { should_not match /^ES_USER=elasticsearch/ }
        end

      end

    end

  end

end
