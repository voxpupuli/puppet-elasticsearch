require 'spec_helper_acceptance'

describe "elasticsearch plugin define:" do

  describe "Install a plugin from official repository" do

    it 'should run successfully' do
      pp = "class { 'elasticsearch': config => { 'node.name' => 'elasticsearch001' }, manage_repo => true, repo_version => '1.0', java_install => true }
            elasticsearch::plugin{'mobz/elasticsearch-head': module_dir => 'head' }
           "

      # Run it twice and test for idempotency
      apply_manifest(pp, :catch_failures => true)
      expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
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
        pp = "class { 'elasticsearch': config => { 'node.name' => 'elasticearch001' }, manage_repo => true, repo_version => '1.0', java_install => true }
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


end

