# == Class: elasticsearch::config
#
# This class exists to coordinate all configuration related actions,
# functionality and logical units in a central place.
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
#   class { 'elasticsearch::config': }
#
# It is not intended to be used directly by external resources like node
# definitions or other modules.
#
#
# === Authors
#
# * Richard Pijnenburg <mailto:richard@ispavailability.com>
#
class elasticsearch::config {

  #### Configuration

  File {
    owner => $elasticsearch::elasticsearch_user,
    group => $elasticsearch::elasticsearch_group
  }

  Exec {
    path => [ '/bin', '/usr/bin', '/usr/local/bin' ],
    cwd  => '/',
  }

  if ( $elasticsearch::ensure == 'present' ) {

    $notify_service = $elasticsearch::restart_on_change ? {
      true  => Class['elasticsearch::service'],
      false => undef,
    }

    file { $elasticsearch::configdir:
      ensure => directory,
      mode   => '0644',
      purge  => $elasticsearch::purge_configdir,
      force  => $elasticsearch::purge_configdir
    }

    file { "${elasticsearch::configdir}/elasticsearch.yml":
      ensure  => file,
      content => template("${module_name}/etc/elasticsearch/elasticsearch.yml.erb"),
      mode    => '0644',
      notify  => $notify_service
    }

    exec { 'mkdir_templates_elasticsearch':
      command => "mkdir -p ${elasticsearch::configdir}/templates_import",
      creates => "${elasticsearch::configdir}/templates_import"
    }

    file { "${elasticsearch::configdir}/templates_import":
      ensure  => 'directory',
      mode    => '0644',
      require => Exec['mkdir_templates_elasticsearch']
    }

    if ( $elasticsearch::datadir != undef ) {
      file { $elasticsearch::datadir:
        ensure  => 'directory',
        owner   => $elasticsearch::elasticsearch_user,
        group   => $elasticsearch::elasticsearch_group,
        mode    => '0770',
      }
    }

  } elsif ( $elasticsearch::ensure == 'absent' ) {

    file { $elasticsearch::configdir:
      ensure  => 'absent',
      recurse => true,
      force   => true
    }

  }

}
