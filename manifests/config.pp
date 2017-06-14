# This class exists to coordinate all configuration related actions,
# functionality and logical units in a central place.
#
# It is not intended to be used directly by external resources like node
# definitions or other modules.
#
# @example importing this class into other classes to use its functionality:
#   class { 'elasticsearch::config': }
#
# @author Richard Pijnenburg <richard.pijnenburg@elasticsearch.com>
# @author Tyler Langlois <tyler.langlois@elastic.co>
#
class elasticsearch::config {

  #### Configuration

  Exec {
    path => [ '/bin', '/usr/bin', '/usr/local/bin' ],
    cwd  => '/',
  }

  if ( $elasticsearch::ensure == 'present' ) {

    file {
      $elasticsearch::configdir:
        ensure => 'directory',
        group  => $elasticsearch::elasticsearch_group,
        owner  => $elasticsearch::elasticsearch_user,
        mode   => '0644';
      $elasticsearch::datadir:
        ensure => 'directory',
        group  => $elasticsearch::elasticsearch_group,
        owner  => $elasticsearch::elasticsearch_user;
      $elasticsearch::logdir:
        ensure  => 'directory',
        group   => undef,
        owner   => $elasticsearch::elasticsearch_user,
        mode    => '0644',
        recurse => true;
      $elasticsearch::plugindir:
        ensure => 'directory',
        group  => $elasticsearch::elasticsearch_group,
        owner  => $elasticsearch::elasticsearch_user,
        mode   => 'o+Xr';
      "${elasticsearch::homedir}/lib":
        ensure  => 'directory',
        group   => '0',
        owner   => 'root',
        recurse => true;
      $elasticsearch::params::homedir:
        ensure => 'directory',
        group  => $elasticsearch::elasticsearch_group,
        owner  => $elasticsearch::elasticsearch_user;
      "${elasticsearch::params::homedir}/templates_import":
        ensure => 'directory',
        group  => $elasticsearch::elasticsearch_group,
        owner  => $elasticsearch::elasticsearch_user,
        mode   => '0644';
      "${elasticsearch::params::homedir}/scripts":
        ensure => 'directory',
        group  => $elasticsearch::elasticsearch_group,
        owner  => $elasticsearch::elasticsearch_user,
        mode   => '0644';
      '/etc/elasticsearch/elasticsearch.yml':
        ensure => 'absent';
      '/etc/elasticsearch/logging.yml':
        ensure => 'absent';
      '/etc/elasticsearch/log4j2.properties':
        ensure => 'absent';
      '/etc/init.d/elasticsearch':
        ensure => 'absent';
    }

    if $elasticsearch::params::pid_dir {
      file { $elasticsearch::params::pid_dir:
        ensure  => 'directory',
        group   => undef,
        owner   => $elasticsearch::elasticsearch_user,
        recurse => true,
      }

      if ($elasticsearch::service_providers == 'systemd') {
        $group = $elasticsearch::elasticsearch_group
        $user = $elasticsearch::elasticsearch_user
        $pid_dir = $elasticsearch::params::pid_dir

        file { '/usr/lib/tmpfiles.d/elasticsearch.conf':
          ensure  => 'file',
          content => template("${module_name}/usr/lib/tmpfiles.d/elasticsearch.conf.erb"),
          group   => '0',
          owner   => 'root',
        }
      }
    }

    if ($elasticsearch::service_providers == 'systemd') {
      # Mask default unit (from package)
      exec { 'systemctl mask elasticsearch.service':
        unless => 'test `systemctl is-enabled elasticsearch.service` = masked',
      }
    }

    $new_init_defaults = { 'CONF_DIR' => $elasticsearch::configdir }
    if $elasticsearch::params::defaults_location {
      augeas { "${elasticsearch::params::defaults_location}/elasticsearch":
        incl    => "${elasticsearch::params::defaults_location}/elasticsearch",
        lens    => 'Shellvars.lns',
        changes => template("${module_name}/etc/sysconfig/defaults.erb"),
      }
    }

    $jvm_options = $elasticsearch::jvm_options
    file { "${elasticsearch::configdir}/jvm.options":
      content => template("${module_name}/etc/elasticsearch/jvm.options.erb"),
      owner   => $elasticsearch::elasticsearch_user,
      group   => $elasticsearch::elasticsearch_group,
    }

    if $::elasticsearch::security_plugin != undef and ($::elasticsearch::security_plugin in ['shield', 'x-pack']) {
      file { "/etc/elasticsearch/${::elasticsearch::security_plugin}" :
        ensure => 'directory',
      }
    }

    # Define logging config file for the in-use security plugin
    if $::elasticsearch::security_logging_content != undef or $::elasticsearch::security_logging_source != undef {
      if $::elasticsearch::security_plugin == undef or ! ($::elasticsearch::security_plugin in ['shield', 'x-pack']) {
        fail("\"${::elasticsearch::security_plugin}\" is not a valid security_plugin parameter value")
      }

      $_security_logging_file = $::elasticsearch::security_plugin ? {
        'shield' => 'logging.yml',
        default => 'log4j2.properties'
      }

      file { "/etc/elasticsearch/${::elasticsearch::security_plugin}/${_security_logging_file}" :
        content => $::elasticsearch::security_logging_content,
        source  => $::elasticsearch::security_logging_source,
      }
    }

  } elsif ( $elasticsearch::ensure == 'absent' ) {

    file { $elasticsearch::plugindir:
      ensure => 'absent',
      force  => true,
      backup => false,
    }

    file { "${elasticsearch::configdir}/jvm.options":
      ensure => 'absent',
    }

  }

}
