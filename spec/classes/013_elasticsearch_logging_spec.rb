require 'spec_helper'

describe 'elasticsearch', :type => 'class' do

  let :facts do {
    :operatingsystem => 'CentOS',
    :kernel => 'Linux',
    :osfamily => 'RedHat'
  } end

  describe "manage the logging.yml file" do

    let :params do {
      :config => { }
    } end

    describe "With default config" do
      it { should contain_file('/etc/elasticsearch/logging.yml').with_content(/^logger.index.search.slowlog: TRACE, index_search_slow_log_file$/).with(:source => nil) }
    end

    describe "With added config via 'logging_config' hash" do
      let :params do {
        :config         => { },
        :logging_config => { 'index.search.slowlog' => 'DEBUG, index_search_slow_log_file' }
      } end

      it { should contain_file('/etc/elasticsearch/logging.yml').with_content(/^logger.index.search.slowlog: DEBUG, index_search_slow_log_file$/).with(:source => nil) }
    end

    describe "With full config via 'logging_file' resource" do
      let :params do {
        :config       => { },
        :logging_file => 'puppet:///path/to/logging.yml'
      } end

      it { should contain_file('/etc/elasticsearch/logging.yml').with(:source => 'puppet:///path/to/logging.yml', :content => nil) }
    end

  end

end
