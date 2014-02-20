require 'spec_helper_acceptance'

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

describe "elasticsearch template define:" do

  shell("mkdir -p #{default['distmoduledir']}/another/files")
  shell("echo '#{good_json}' >> #{default['distmoduledir']}/another/files/good.json")
  shell("echo '#{bad_json}' >> #{default['distmoduledir']}/another/files/bad.json")

  describe "Insert a template with valid json content" do

    it 'should run successfully' do
      pp = "class { 'elasticsearch': config => { 'node.name' => 'elasticsearch001' }, manage_repo => true, repo_version => '1.0', java_install => true }
          elasticsearch::template { 'foo': ensure => 'present', file => 'puppet:///modules/another/good.json' }"

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
    end

    it 'should report as existing in Elasticsearch' do
      shell("/usr/bin/curl http://localhost:9200/_template/foo | grep logstash", {:acceptable_exit_codes => 0})
    end
  end

  if fact('puppetversion') =~ /3\.[2-9]\./
    describe "Insert a template with bad json content" do

      it 'run should fail' do
        pp = "class { 'elasticsearch': config => { 'node.name' => 'elasticsearch001' }, manage_repo => true, repo_version => '1.0', java_install => true }
             elasticsearch::template { 'foo': ensure => 'present', file => 'puppet:///modules/another/bad.json' }"

        apply_manifest(pp, :expect_failures => true)
      end

    end

  else
    # The exit codes have changes since Puppet 3.2x
    # Since beaker expectations are based on the most recent puppet code All runs on previous versions fails.
  end

end
