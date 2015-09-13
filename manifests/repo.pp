# == Class: elasticsearch::repo
#
# This class exists to install and manage yum and apt repositories
# that contain elasticsearch official elasticsearch packages
#
#
# === Parameters
#
# This class does not provide any parameters.
#
#
# === Examples
#
# This class may be imported by other classes to use its functionality:
#   class { 'elasticsearch::repo': }
#
# It is not intended to be used directly by external resources like node
# definitions or other modules.
#
#
# === Authors
#
# * Phil Fenstermacher <mailto:phillip.fenstermacher@gmail.com>
# * Richard Pijnenburg <mailto:richard.pijnenburg@elasticsearch.com>
#
class elasticsearch::repo {

  Exec {
    path      => [ '/bin', '/usr/bin', '/usr/local/bin' ],
    cwd       => '/',
  }

  case $::osfamily {
    'Debian': {
      if !defined(Class['apt']) {
        class { 'apt': }
      }

      apt::source { 'elasticsearch':
        location    => "http://packages.elastic.co/elasticsearch/${elasticsearch::repo_version}/debian",
        release     => 'stable',
        repos       => 'main',
        key         => '46095ACC8548582C1A2699A9D27D666CD88E42B4',
        key_source  => 'http://packages.elastic.co/GPG-KEY-elasticsearch',
        include_src => false,
      }
    }
    'RedHat', 'Linux': {
      yumrepo { 'elasticsearch':
        descr    => 'elasticsearch repo',
        baseurl  => "http://packages.elastic.co/elasticsearch/${elasticsearch::repo_version}/centos",
        gpgcheck => 1,
        gpgkey   => 'http://packages.elastic.co/GPG-KEY-elasticsearch',
        enabled  => 1,
      }
    }
    'Suse': {
      exec { 'elasticsearch_suse_import_gpg':
        command => 'rpmkeys --import http://packages.elastic.co/GPG-KEY-elasticsearch',
        unless  => 'test $(rpm -qa gpg-pubkey | grep -i "D88E42B4" | wc -l) -eq 1 ',
        notify  => [ Zypprepo['elasticsearch'] ],
      }

      zypprepo { 'elasticsearch':
        baseurl     => "http://packages.elastic.co/elasticsearch/${elasticsearch::repo_version}/centos",
        enabled     => 1,
        autorefresh => 1,
        name        => 'elasticsearch',
        gpgcheck    => 1,
        gpgkey      => 'http://packages.elastic.co/GPG-KEY-elasticsearch',
        type        => 'yum',
      }
    }
    default: {
      fail("\"${module_name}\" provides no repository information for OSfamily \"${::osfamily}\"")
    }
  }

  # Package pinning
  if ($elasticsearch::package_pin == true and $elasticsearch::version != false) {
    case $::osfamily {
      'Debian': {
        if !defined(Class['apt']) {
          class { 'apt': }
        }

        apt::pin { $elasticsearch::package_name:
          ensure   => 'present',
          packages => $elasticsearch::package_name,
          version  => $elasticsearch::real_version,
          priority => 1000,
        }
      }
      'RedHat', 'Linux': {

        yum::versionlock { "0:elasticsearch-${elasticsearch::real_version}.noarch":
          ensure => 'present',
        }
      }
      default: {
        warning("Unable to pin package for OSfamily \"${::osfamily}\".")
      }
    }
  }

}
