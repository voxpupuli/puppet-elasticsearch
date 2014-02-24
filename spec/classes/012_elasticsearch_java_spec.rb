require 'spec_helper'

describe 'elasticsearch', :type => 'class' do

  context "install java" do

    let :params do {
      :java_install => true,
      :config => { 'node' => { 'name' => 'test' }  }
    } end

    context "On Debian OS" do

      let :facts do {
        :operatingsystem => 'Debian',
        :kernel => 'Linux',
        :osfamily => 'Debian'

      } end

      it { should contain_class('elasticsearch::java').that_requires('Anchor[elasticsearch::begin]') }
      it { should contain_class('elasticsearch::package').that_requires('Class[elasticsearch::java]') }
      it { should contain_package('openjdk-7-jre-headless') }

    end

    context "On Ubuntu OS" do

      let :facts do {
        :operatingsystem => 'Ubuntu',
         :kernel => 'Linux',
        :osfamily => 'Debian'

      } end

      it { should contain_class('elasticsearch::java') }
      it { should contain_class('elasticsearch::package').that_requires('Class[elasticsearch::java]') }
      it { should contain_package('openjdk-7-jre-headless') }

    end

    context "On CentOS OS " do

      let :facts do {
        :operatingsystem => 'CentOS',
        :kernel => 'Linux',
        :osfamily => 'RedHat'

      } end

      it { should contain_class('elasticsearch::java') }
      it { should contain_class('elasticsearch::package').that_requires('Class[elasticsearch::java]') }
      it { should contain_package('java-1.7.0-openjdk') }

    end

    context "On RedHat OS " do

      let :facts do {
        :operatingsystem => 'Redhat',
        :kernel => 'Linux',
        :osfamily => 'RedHat'

      } end

      it { should contain_class('elasticsearch::java') }
      it { should contain_class('elasticsearch::package').that_requires('Class[elasticsearch::java]') }
      it { should contain_package('java-1.7.0-openjdk') }

    end

    context "On Fedora OS " do

      let :facts do {
        :operatingsystem => 'Fedora',
        :kernel => 'Linux',
        :osfamily => 'RedHat'
      } end

      it { should contain_class('elasticsearch::java') }
      it { should contain_class('elasticsearch::package').that_requires('Class[elasticsearch::java]') }
      it { should contain_package('java-1.7.0-openjdk') }

    end

    context "On Scientific OS " do

      let :facts do {
        :operatingsystem => 'Scientific',
        :kernel => 'Linux',
        :osfamily => 'RedHat'
      } end

      it { should contain_class('elasticsearch::java') }
      it { should contain_class('elasticsearch::package').that_requires('Class[elasticsearch::java]') }
      it { should contain_package('java-1.7.0-openjdk') }

    end

    context "On Amazon OS " do

      let :facts do {
        :operatingsystem => 'Amazon',
        :kernel => 'Linux',
        :osfamily => 'RedHat'
      } end

      it { should contain_class('elasticsearch::java') }
      it { should contain_class('elasticsearch::package').that_requires('Class[elasticsearch::java]') }
      it { should contain_package('java-1.7.0-openjdk') }

    end

    context "On OracleLinux OS " do

      let :facts do {
        :operatingsystem => 'OracleLinux',
        :kernel => 'Linux',
        :osfamily => 'RedHat'
      } end

      it { should contain_class('elasticsearch::java') }
      it { should contain_class('elasticsearch::package').that_requires('Class[elasticsearch::java]') }
      it { should contain_package('java-1.7.0-openjdk') }

    end

    context "On an unknown OS" do

      let :facts do {
        :operatingsystem => 'Windows'
      } end

      it { expect { should raise_error(Puppet::Error) } }

    end

    context "Custom java package" do

      let :facts do {
        :operatingsystem => 'CentOS',
        :kernel => 'Linux',
        :osfamily => 'RedHat'
     } end

      let :params do {
        :java_install => true,
        :java_package => 'java-1.6.0-openjdk',
        :config => { 'node' => { 'name' => 'test' }  }
      } end

      it { should contain_class('elasticsearch::java') }
      it { should contain_class('elasticsearch::package').that_requires('Class[elasticsearch::java]') }
      it { should contain_package('java-1.6.0-openjdk') }

    end

  end

end
