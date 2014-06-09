require 'spec_helper_acceptance'

  case fact('osfamily')
    when 'RedHat'
      package_name = 'elasticsearch'
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
      package_name = 'elasticsearch'
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


  good_json='{
  "template" : "logstash-*",
  "settings" : {
    "index.refresh_interval" : "5s",
    "analysis" : {
      "analyzer" : {
        "default" : {
          "type" : "standard",
          "stopwords" : "_none_"
        }
      }
    }
  },
  "mappings" : {
    "_default_" : {
       "_all" : {"enabled" : true},
       "dynamic_templates" : [ {
         "string_fields" : {
           "match" : "*",
           "match_mapping_type" : "string",
           "mapping" : {
             "type" : "multi_field",
               "fields" : {
                 "{name}" : {"type": "string", "index" : "analyzed", "omit_norms" : true },
                 "raw" : {"type": "string", "index" : "not_analyzed", "ignore_above" : 256}
               }
           }
         }
       } ],
       "properties" : {
         "@version": { "type": "string", "index": "not_analyzed" },
         "geoip"  : {
           "type" : "object",
             "dynamic": true,
             "path": "full",
             "properties" : {
               "location" : { "type" : "geo_point" }
             }
         }
       }
    }
  }
}
'

  bad_json='{
  "settings" : {
    "index.refresh_interval" : "5s",
    "analysis" : {
      "analyzer" : {
        "default" : {
          "type" : "standard",
          "stopwords" : "_none_"
        }
      }
    }
  },
  "mappings" : {
    "_default_" : {
       "_all" : {"enabled" : true},
       "dynamic_templates" : [ {
         "string_fields" : {
           "match" : "*",
           "match_mapping_type" : "string",
           "mapping" : {
             "type" : "multi_field",
               "fields" : {
                 "{name}" : {"type": "string", "index" : "analyzed", "omit_norms" : true },
                 "raw" : {"type": "string", "index" : "not_analyzed", "ignore_above" : 256}
               }
           }
         }
       } ],
       "properties" : {
         "@version": { "type": "string", "index": "not_analyzed" },
         "geoip"  : {
           "type" : "object",
             "dynamic": true,
             "path": "full",
             "properties" : {
               "location" : { "type" : "geo_point" }
             }
         }
       }
    }
  }
}
'


cluster_name = SecureRandom.hex(10)

describe "elasticsearch template define:" do

  shell("mkdir -p #{default['distmoduledir']}/another/files")
  shell("echo '#{good_json}' >> #{default['distmoduledir']}/another/files/good.json")
  shell("echo '#{bad_json}' >> #{default['distmoduledir']}/another/files/bad.json")

  describe "Insert a template with valid json content" do

    it 'should run successfully' do
      pp = "class { 'elasticsearch': config => { 'node.name' => 'elasticsearch001', 'cluster.name' => '#{cluster_name}' }, manage_repo => true, repo_version => '1.0', java_install => true }
          elasticsearch::instance { 'es-01': config => { 'node.name' => 'elasticsearch001', 'http.port' => '#{port_a}' } }
          elasticsearch::template { 'foo': ensure => 'present', file => 'puppet:///modules/another/good.json' }"

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end

    it 'should report as existing in Elasticsearch' do
      curl_with_retries('validate template as installed', default, 'http://localhost:9200/_template/foo | grep logstash', 0)
    end
  end

  if fact('puppetversion') =~ /3\.[2-9]\./
    describe "Insert a template with bad json content" do

      it 'run should fail' do
        pp = "class { 'elasticsearch': config => { 'node.name' => 'elasticsearch001', 'cluster.name' => '#{cluster_name}' }, manage_repo => true, repo_version => '1.0', java_install => true }
             elasticsearch::instance { 'es-01': config => { 'node.name' => 'elasticsearch001', 'http.port' => '#{port_a}' } }
             elasticsearch::template { 'foo': ensure => 'present', file => 'puppet:///modules/another/bad.json' }"

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


end
