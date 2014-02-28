require 'spec_helper_acceptance'

describe "Service tests:" do

  case fact('osfamily')
    when 'RedHat'
      defaults_file = '/etc/sysconfig/elasticsearch'
    when 'Debian'
      defaults_file = '/etc/default/elasticsearch'
    when 'Suse'
      defaults_file = '/etc/sysconfig/elasticsearch'
  end


  describe "Make sure we can manage the defaults file" do

    context "Change the defaults file" do
      it 'should run successfully' do
        pp = "class { 'elasticsearch': manage_repo => true, repo_version => '1.0', java_install => true, config => { 'node.name' => 'elasticsearch001' }, init_defaults => { 'ES_USER' => 'root' } }"

        # Run it twice and test for idempotency
        apply_manifest(pp, :catch_failures => true)
        sleep 10
        expect(apply_manifest(pp, :catch_failures => true).exit_code).to be_zero
      end
    end

    context "Make sure we have ES_USER=root" do

      describe file(defaults_file) do
        its(:content) { should match /^ES_USER=root/ }
        its(:content) { should_not match /^ES_USER=elasticsearch/ }
      end

    end

  end

end
