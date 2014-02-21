require 'spec_helper'

describe 'elasticsearch::ruby', :type => 'define' do

  let :facts do {
    :operatingsystem => 'CentOS',
    :kernel => 'Linux',
    :osfamily => 'RedHat'
  } end

  [ 'tire', 'stretcher', 'elastic_searchable', 'elasticsearch'].each do |rubylib|

    context "installation of library #{rubylib}" do

      let(:title) { rubylib }

      it { should contain_elasticsearch__ruby(rubylib) }
      it { should contain_package(rubylib).with(:provider => 'gem') }

    end

  end

end
