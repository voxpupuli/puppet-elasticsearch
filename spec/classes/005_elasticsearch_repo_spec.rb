require 'spec_helper'

describe 'elasticsearch', :type => 'class' do

  default_params = {
    :config => {},
    :manage_repo => true,
    :repo_version => '1.3'
  }

  on_supported_os.each do |os, facts|

    context "on #{os}" do


      let(:facts) do
        facts.merge({ 'scenario' => '', 'common' => '' })
      end

      let (:params) do
        default_params
      end

      context "Use anchor type for ordering" do

        let :params do
          default_params
        end

        it { should contain_class('elasticsearch::repo').that_requires('Anchor[elasticsearch::begin]') }
      end


      context "Use stage type for ordering" do

        let :params do
          default_params.merge({
            :repo_stage => 'setup'
          })
        end

        it { should contain_stage('setup') }
        it { should contain_class('elasticsearch::repo').with(:stage => 'setup') }

      end

      case facts[:osfamily]
      when 'Debian'
        context 'has apt repo parts' do
          it { should contain_apt__source('elasticsearch').with(:location => 'http://packages.elasticsearch.org/elasticsearch/1.3/debian') }
        end
      when 'RedHat'
        context 'has yum repo parts' do
          it { should contain_yumrepo('elasticsearch').with(:baseurl => 'http://packages.elasticsearch.org/elasticsearch/1.3/centos') }
        end
      when 'Suse'
        context 'has zypper repo parts' do
          it { should contain_exec('elasticsearch_suse_import_gpg').with(:command => 'rpmkeys --import http://packages.elasticsearch.org/GPG-KEY-elasticsearch') }
          it { should contain_zypprepo('elasticsearch').with(:baseurl => 'http://packages.elasticsearch.org/elasticsearch/1.3/centos') }
        end
      end

    
    end
  end
end
