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
    path => [ '/bin', '/usr/bin', '/usr/local/bin' ],
    cwd  => '/',
  }

  case $::osfamily {
    'Debian': {
      include ::apt
      Class['apt::update'] -> Package[$elasticsearch::package_name]

      apt::source { 'elasticsearch':
        ensure      => $elasticsearch::ensure,
        location    => "http://packages.elastic.co/elasticsearch/${elasticsearch::repo_version}/debian",
        release     => 'stable',
        repos       => 'main',
        key         => $::elasticsearch::repo_key_id,
        key_source  => $::elasticsearch::repo_key_source,
        include_src => false,
      }
    }
    'RedHat', 'Linux': {
      yumrepo { 'elasticsearch':
        ensure   => $elasticsearch::ensure,
        descr    => 'elasticsearch repo',
        baseurl  => "http://packages.elastic.co/elasticsearch/${elasticsearch::repo_version}/centos",
        gpgcheck => 1,
        gpgkey   => $::elasticsearch::repo_key_source,
        enabled  => 1,
        proxy    => $::elasticsearch::repo_proxy,
      } ~>
      exec { 'elasticsearch_yumrepo_yum_clean':
        command     => 'yum clean metadata expire-cache --disablerepo="*" --enablerepo="elasticsearch"',
        refreshonly => true,
        returns     => [0, 1],
      }
    }
    'Suse': {
      if $::operatingsystem == 'SLES' and versioncmp($::operatingsystemmajrelease, '11') <= 0 {
        # Older versions of SLES do not ship with rpmkeys
        $_import_cmd = "rpm --import ${::elasticsearch::repo_key_source}"
      } else {
        $_import_cmd = "rpmkeys --import ${::elasticsearch::repo_key_source}"
      }

      exec { 'elasticsearch_suse_import_gpg':
        command => $_import_cmd,
        unless  => "test $(rpm -qa gpg-pubkey | grep -i '${::elasticsearch::repo_key_id}' | wc -l) -eq 1 ",
        notify  => [ Zypprepo['elasticsearch'] ],
      }

      zypprepo { 'elasticsearch':
        ensure      => $elasticsearch::ensure,
        baseurl     => "http://packages.elastic.co/elasticsearch/${elasticsearch::repo_version}/centos",
        enabled     => 1,
        autorefresh => 1,
        name        => 'elasticsearch',
        gpgcheck    => 1,
        gpgkey      => $::elasticsearch::repo_key_source,
        type        => 'yum',
      } ~>
      exec { 'elasticsearch_zypper_refresh_elasticsearch':
        command     => 'zypper refresh elasticsearch',
        refreshonly => true,
      }
    }
    default: {
      fail("\"${module_name}\" provides no repository information for OSfamily \"${::osfamily}\"")
    }
  }

  # Package pinning

  case $::osfamily {
    'Debian': {
      include ::apt

      if ($elasticsearch::ensure == 'absent') {
        apt::pin { $elasticsearch::package_name:
          ensure => $elasticsearch::ensure,
        }
      } elsif ($elasticsearch::package_pin == true and $elasticsearch::version != false) {
        apt::pin { $elasticsearch::package_name:
          ensure   => $elasticsearch::ensure,
          packages => $elasticsearch::package_name,
          version  => $elasticsearch::version,
          priority => 1000,
        }
      }

    }
    'RedHat', 'Linux': {

      if ($elasticsearch::ensure == 'absent') {
        $_versionlock = '/etc/yum/pluginconf.d/versionlock.list'
        exec { 'elasticsearch_purge_versionlock.list':
          command => "sed -i '/0:elasticsearch-/d' ${_versionlock}",
          onlyif  => "test -f ${_versionlock}",
          before  => Yumrepo['elasticsearch'],
        }
      } elsif ($elasticsearch::package_pin == true and $elasticsearch::version != false) {
        yum::versionlock { "0:elasticsearch-${elasticsearch::pkg_version}.noarch":
          ensure => $elasticsearch::ensure,
          before => Yumrepo['elasticsearch'],
        }
      }

    }
    default: {
      warning("Unable to pin package for OSfamily \"${::osfamily}\".")
    }
  }
}
