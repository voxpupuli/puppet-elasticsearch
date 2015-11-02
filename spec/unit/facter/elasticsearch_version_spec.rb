require "spec_helper"

describe Facter::Util::Fact do
  before {
    Facter.clear
  }

  describe "elasticsearch_version" do
    context 'returns elasticsearch version when elasticsearch < 2.0.0 present' do
      it do
        es_version_output = <<-EOS
Version: 1.4.7, Build: de54438/2015-10-22T08:09:48Z, JVM: 1.7.0_71
        EOS
        Facter::Core::Execution.expects(:exec).with("/usr/share/elasticsearch/bin/elasticsearch -v").returns(es_version_output)
        expect(Facter.value(:elasticsearch_version)).to eq("1.4.7")
      end
    end
    context 'returns elasticsearch version when elasticsearch >= 2.0.0 present' do
      it do
        es_version_output = <<-EOS
Version: 2.0.0, Build: de54438/2015-10-22T08:09:48Z, JVM: 1.8.0_66
        EOS
        Facter::Core::Execution.expects(:exec).with("/usr/share/elasticsearch/bin/elasticsearch -v").returns("")
        Facter::Core::Execution.expects(:exec).with("/usr/share/elasticsearch/bin/elasticsearch --version").returns(es_version_output)
        expect(Facter.value(:elasticsearch_version)).to eq("2.0.0")
      end
    end

    context 'returns nil when elasticsearch not present' do
      it do
        Facter::Core::Execution.stubs(:exec)
        expect(Facter.value(:elasticsearch_version)).to be_nil
      end
    end
  end
end
