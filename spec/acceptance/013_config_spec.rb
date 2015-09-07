require 'spec_helper_acceptance'

describe "elasticsearch class:" do

  describe "Setup single instance" do

    it 'should run successfully' do
      pp = "class { 'elasticsearch': config => { 'cluster.name' => '#{test_settings['cluster_name']}'}, manage_repo => true, repo_version => '#{test_settings['repo_version']}', java_install => true }
            elasticsearch::instance { 'es-01': config => { 'node.name' => 'elasticsearch001', 'http.port' => '#{test_settings['port_a']}' } }
           "

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end


    describe service(test_settings['service_name_a']) do
      it { should be_enabled }
      it { should be_running }
    end

    describe package(test_settings['package_name']) do
      it { should be_installed }
    end

    describe file(test_settings['pid_file_a']) do
      it { should be_file }
      its(:content) { should match /[0-9]+/ }
    end

    describe "Elasticsearch serves requests on" do
      it {
        curl_with_retries("check ES on #{test_settings['port_a']}", default, "http://localhost:#{test_settings['port_a']}/?pretty=true", 0)
      }
    end

    describe file('/etc/elasticsearch/es-01/elasticsearch.yml') do
      it { should be_file }
      it { should contain 'name: elasticsearch001' }
    end

    describe file('/usr/share/elasticsearch/templates_import') do
      it { should be_directory }
    end

    describe file('/usr/share/elasticsearch/scripts') do
      it { should be_directory }
    end

    describe file('/etc/elasticsearch/es-01/scripts') do
      it { should be_symlink }
    end

  end

  #### TODO: Modify rspec-puppet assertions of config to acceptance tests. Required due to move to datacat ####

    context "set a value" do

      let :params do {
        :config => { 'node.name' => 'test'   }
      } end

      it { should contain_datacat_fragment('main_config_es-01') }
      it { should contain_datacat('/etc/elasticsearch/es-01/elasticsearch.yml') }
      #it { should contain_file('/etc/elasticsearch/es-01/elasticsearch.yml').with(:content => "### MANAGED BY PUPPET ###\n---\nnode: \n  name: test\npath: \n  data: /usr/share/elasticsearch/data/es-01\n") }

    end

    context "set a value to true" do

      let :params do {
        :config => { 'node' => { 'master' => true }  }
      } end
      it { should contain_datacat_fragment('main_config_es-01') }
      it { should contain_datacat('/etc/elasticsearch/es-01/elasticsearch.yml') }

#      it { should contain_file('/etc/elasticsearch/es-01/elasticsearch.yml').with(:content => "### MANAGED BY PUPPET ###\n---\nnode: \n  master: true\n  name: foo-es-01\npath: \n  data: /usr/share/elasticsearch/data/es-01\n") }

    end

    context "set a value to false" do

      let :params do {
        :config => { 'node' => { 'data' => false }  }
      } end
      it { should contain_datacat_fragment('main_config_es-01') }
      it { should contain_datacat('/etc/elasticsearch/es-01/elasticsearch.yml') }

#      it { should contain_file('/etc/elasticsearch/es-01/elasticsearch.yml').with(:content => "### MANAGED BY PUPPET ###\n---\nnode: \n  data: false\n  name: foo-es-01\npath: \n  data: /usr/share/elasticsearch/data/es-01\n") }

    end

    context "deeper hash and multiple keys" do

      let :params do {
        :config => { 'index' => { 'routing' => { 'allocation' => { 'include' => 'tag1', 'exclude' => [ 'tag2', 'tag3' ] } } }, 'node.name' => 'somename'  }
      } end
      it { should contain_datacat_fragment('main_config_es-01') }
      it { should contain_datacat('/etc/elasticsearch/es-01/elasticsearch.yml') }

#      it { should contain_file('/etc/elasticsearch/es-01/elasticsearch.yml').with(:content => "### MANAGED BY PUPPET ###\n---\nindex: \n  routing: \n    allocation: \n      exclude: \n             - tag2\n             - tag3\n      include: tag1\nnode: \n  name: somename\npath: \n  data: /usr/share/elasticsearch/data/es-01\n") }

    end

    context "Combination of full hash and shorted write up keys" do

      let :params do {
        :config => { 'node' => { 'name' => 'NodeName', 'rack' => 46 }, 'boostrap.mlockall' => true, 'cluster' => { 'name' => 'ClusterName', 'routing.allocation.awareness.attributes' => 'rack' }, 'discovery.zen' => { 'ping.unicast.hosts'=> [ "host1", "host2" ], 'minimum_master_nodes' => 3, 'ping.multicast.enabled' => false }, 'gateway' => { 'expected_nodes' => 4, 'recover_after_nodes' => 3 }, 'network.host' => '123.123.123.123' }
       } end
      it { should contain_datacat_fragment('main_config_es-01') }
      it { should contain_datacat('/etc/elasticsearch/es-01/elasticsearch.yml') }

#      it { should contain_file('/etc/elasticsearch/es-01/elasticsearch.yml').with(:content => "### MANAGED BY PUPPET ###\n---\nboostrap: \n  mlockall: true\ncluster: \n  name: ClusterName\n  routing: \n    allocation: \n      awareness: \n        attributes: rack\ndiscovery: \n  zen: \n    minimum_master_nodes: 3\n    ping: \n      multicast: \n        enabled: false\n      unicast: \n        hosts: \n             - host1\n             - host2\ngateway: \n  expected_nodes: 4\n  recover_after_nodes: 3\nnetwork: \n  host: 123.123.123.123\nnode: \n  name: NodeName\n  rack: 46\npath: \n  data: /usr/share/elasticsearch/data/es-01\n") }

    end

    context "merge Main class and instance configs together" do
      let(:pre_condition) { 'class {"elasticsearch": config => { "cluster.name" => "somename"} }' }
      let :params do {
        :config => { 'node.name' => 'NodeName' }
      } end
      it { should contain_datacat_fragment('main_config_es-01') }
      it { should contain_datacat('/etc/elasticsearch/es-01/elasticsearch.yml') }

#      it { should contain_file('/etc/elasticsearch/es-01/elasticsearch.yml').with(:content => "### MANAGED BY PUPPET ###\n---\ncluster: \n  name: somename\nnode: \n  name: NodeName\npath: \n  data: /usr/share/elasticsearch/data/es-01\n") }

    end

    context "override main class confgi with instance config" do
      let(:pre_condition) { 'class {"elasticsearch": config => { "cluster.name" => "somename" } }'  }
      let :params do {
        :config => { 'node.name' => 'NodeName', 'cluster.name' => 'ClusterName' }
      } end
      it { should contain_datacat_fragment('main_config_es-01') }
      it { should contain_datacat('/etc/elasticsearch/es-01/elasticsearch.yml') }

#      it { should contain_file('/etc/elasticsearch/es-01/elasticsearch.yml').with(:content => "### MANAGED BY PUPPET ###\n---\ncluster: \n  name: ClusterName\nnode: \n  name: NodeName\npath: \n  data: /usr/share/elasticsearch/data/es-01\n") }
    end


  context "data directory" do
    let(:pre_condition) { 'class {"elasticsearch": }'  }

    context "default" do
      it { should contain_exec('mkdir_datadir_elasticsearch_es-01') }
#      it { should contain_file('/etc/elasticsearch/es-01/elasticsearch.yml').with(:content => "### MANAGED BY PUPPET ###\n---\nnode: \n  name: foo-es-01\npath: \n  data: /usr/share/elasticsearch/data/es-01\n" ) }a
      it { should contain_datacat_fragment('main_config_es-01') }
      it { should contain_datacat('/etc/elasticsearch/es-01/elasticsearch.yml') }

      it { should contain_file('/usr/share/elasticsearch/data/es-01').with( :ensure => 'directory') }
      it { should contain_file('/usr/share/elasticsearch/data').with( :ensure => 'directory') }
    end

    context "single from main config " do
      let(:pre_condition) { 'class {"elasticsearch": datadir => "/var/lib/elasticsearch-data" }'  }
      it { should contain_exec('mkdir_datadir_elasticsearch_es-01') }
#      it { should contain_file('/etc/elasticsearch/es-01/elasticsearch.yml').with(:content => "### MANAGED BY PUPPET ###\n---\nnode: \n  name: foo-es-01\npath: \n  data: /var/lib/elasticsearch-data/es-01\n" ) }
      it { should contain_datacat_fragment('main_config_es-01') }
      it { should contain_datacat('/etc/elasticsearch/es-01/elasticsearch.yml') }

      it { should contain_file('/var/lib/elasticsearch-data').with( :ensure => 'directory') }
      it { should contain_file('/var/lib/elasticsearch-data/es-01').with( :ensure => 'directory') }
    end

    context "single from instance config" do
      let(:pre_condition) { 'class {"elasticsearch": }'  }
      let :params do {
        :datadir => '/var/lib/elasticsearch/data'
      } end

      it { should contain_exec('mkdir_datadir_elasticsearch_es-01') }
      it { should contain_datacat_fragment('main_config_es-01') }
      it { should contain_datacat('/etc/elasticsearch/es-01/elasticsearch.yml') }

#      it { should contain_file('/etc/elasticsearch/es-01/elasticsearch.yml').with(:content => "### MANAGED BY PUPPET ###\n---\nnode: \n  name: foo-es-01\npath: \n  data: /var/lib/elasticsearch/data\n" ) }
      it { should contain_file('/var/lib/elasticsearch/data').with( :ensure => 'directory') }
    end

    context "multiple from main config" do
      let(:pre_condition) { 'class {"elasticsearch": datadir => [ "/var/lib/elasticsearch-data01", "/var/lib/elasticsearch-data02"] }'  }
      it { should contain_exec('mkdir_datadir_elasticsearch_es-01') }
      it { should contain_datacat_fragment('main_config_es-01') }
      it { should contain_datacat('/etc/elasticsearch/es-01/elasticsearch.yml') }

#      it { should contain_file('/etc/elasticsearch/es-01/elasticsearch.yml').with(:content => "### MANAGED BY PUPPET ###\n---\nnode: \n  name: foo-es-01\npath: \n  data: \n      - /var/lib/elasticsearch-data01/es-01\n      - /var/lib/elasticsearch-data02/es-01\n" ) }
      it { should contain_file('/var/lib/elasticsearch-data01').with( :ensure => 'directory') }
      it { should contain_file('/var/lib/elasticsearch-data01/es-01').with( :ensure => 'directory') }
      it { should contain_file('/var/lib/elasticsearch-data02').with( :ensure => 'directory') }
      it { should contain_file('/var/lib/elasticsearch-data02/es-01').with( :ensure => 'directory') }
    end

    context "multiple from instance config" do
      let(:pre_condition) { 'class {"elasticsearch": }'  }
      let :params do {
        :datadir => ['/var/lib/elasticsearch-data/01', '/var/lib/elasticsearch-data/02']
      } end

      it { should contain_exec('mkdir_datadir_elasticsearch_es-01') }
      it { should contain_datacat_fragment('main_config_es-01') }
      it { should contain_datacat('/etc/elasticsearch/es-01/elasticsearch.yml') }

#      it { should contain_file('/etc/elasticsearch/es-01/elasticsearch.yml').with(:content => "### MANAGED BY PUPPET ###\n---\nnode: \n  name: foo-es-01\npath: \n  data: \n      - /var/lib/elasticsearch-data/01\n      - /var/lib/elasticsearch-data/02\n" ) }
      it { should contain_file('/var/lib/elasticsearch-data/01').with( :ensure => 'directory') }
      it { should contain_file('/var/lib/elasticsearch-data/02').with( :ensure => 'directory') }
    end

   context "Conflicting setting path.data" do
     let(:pre_condition) { 'class {"elasticsearch": }'  }
     let :params do {
       :datadir => '/var/lib/elasticsearch/data',
       :config  => { 'path.data' => '/var/lib/elasticsearch/otherdata' }
     } end

      it { should contain_exec('mkdir_datadir_elasticsearch_es-01') }
      it { should contain_datacat_fragment('main_config_es-01') }
      it { should contain_datacat('/etc/elasticsearch/es-01/elasticsearch.yml') }

#      it { should contain_file('/etc/elasticsearch/es-01/elasticsearch.yml').with(:content => "### MANAGED BY PUPPET ###\n---\nnode: \n  name: foo-es-01\npath: \n  data: /var/lib/elasticsearch/data\n" ) }
      it { should contain_file('/var/lib/elasticsearch/data').with( :ensure => 'directory') }
      it { should_not contain_file('/var/lib/elasticsearch/otherdata').with( :ensure => 'directory') }
   end

   context "Conflicting setting path => data" do
     let(:pre_condition) { 'class {"elasticsearch": }'  }
     let :params do {
       :datadir => '/var/lib/elasticsearch/data',
       :config  => { 'path' => { 'data' => '/var/lib/elasticsearch/otherdata' } }
     } end

      it { should contain_exec('mkdir_datadir_elasticsearch_es-01') }
      it { should contain_datacat_fragment('main_config_es-01') }
      it { should contain_datacat('/etc/elasticsearch/es-01/elasticsearch.yml') }

#      it { should contain_file('/etc/elasticsearch/es-01/elasticsearch.yml').with(:content => "### MANAGED BY PUPPET ###\n---\nnode: \n  name: foo-es-01\npath: \n  data: /var/lib/elasticsearch/data\n" ) }
      it { should contain_file('/var/lib/elasticsearch/data').with( :ensure => 'directory') }
      it { should_not contain_file('/var/lib/elasticsearch/otherdata').with( :ensure => 'directory') }
   end

   context "With other path options defined" do
     let(:pre_condition) { 'class {"elasticsearch": }'  }
     let :params do {
       :datadir => '/var/lib/elasticsearch/data',
       :config  => { 'path' => { 'home' => '/var/lib/elasticsearch' } }
     } end

      it { should contain_exec('mkdir_datadir_elasticsearch_es-01') }
      it { should contain_datacat_fragment('main_config_es-01') }
      it { should contain_datacat('/etc/elasticsearch/es-01/elasticsearch.yml') }

#      it { should contain_file('/etc/elasticsearch/es-01/elasticsearch.yml').with(:content => "### MANAGED BY PUPPET ###\n---\nnode: \n  name: foo-es-01\npath: \n  data: /var/lib/elasticsearch/data\n  home: /var/lib/elasticsearch\n" ) }
      it { should contain_file('/var/lib/elasticsearch/data').with( :ensure => 'directory') }
   end


  describe "Cleanup" do

    it 'should run successfully' do
      pp = "class { 'elasticsearch': ensure => 'absent' }
            elasticsearch::instance{ 'es-01': ensure => 'absent' }
           "

      apply_manifest(pp, :catch_failures => true)
    end

    describe file('/etc/elasticsearch/es-01') do
      it { should_not be_directory }
    end

    describe service(test_settings['service_name_a']) do
      it { should_not be_enabled }
      it { should_not be_running }
    end

  end

end
