# This class exists to coordinate all service management related actions,
# functionality and logical units in a central place.
#
# *Note*: "service" is the Puppet term and type for background processes
# in general and is used in a platform-independent way. E.g. "service" means
# "daemon" in relation to Unix-like systems.
#
# @param ensure [String]
#   Controls if the managed resources shall be `present` or
#   `absent`. If set to `absent`, the managed software packages will being
#   uninstalled and any traces of the packages will be purged as well as
#   possible. This may include existing configuration files (the exact
#   behavior is provider). This is thus destructive and should be used with
#   care.
#
# @param init_defaults [Hash]
#   Defaults file content in hash representation
#
# @param init_defaults_file [String]
#   Defaults file as puppet resource
#
# @param init_template [String]
#   Service file as a template
#
# @param status [String]
#   Defines the status of the service. If set to `enabled`, the service is
#   started and will be enabled at boot time. If set to `disabled`, the
#   service is stopped and will not be started at boot time. If set to `running`,
#   the service is started but will not be enabled at boot time. You may use
#   this to start a service on the first Puppet run instead of the system startup.
#   If set to `unmanaged`, the service will not be started at boot time and Puppet
#   does not care whether the service is running or not. For example, this may
#   be useful if a cluster management software is used to decide when to start
#   the service plus assuring it is running on the desired node.
#
# @author Richard Pijnenburg <richard.pijnenburg@elasticsearch.com>
# @author Tyler Langlois <tyler.langlois@elastic.co>
#
define elasticsearch::service::openrc(
  $ensure             = $elasticsearch::ensure,
  $init_defaults      = undef,
  $init_defaults_file = undef,
  $init_template      = undef,
  $status             = $elasticsearch::status,
) {

  #### Service management

  # set params: in operation
  if $ensure == 'present' {

    case $status {
      # make sure service is currently running, start it on boot
      'enabled': {
        $service_ensure = 'running'
        $service_enable = true
      }
      # make sure service is currently stopped, do not start it on boot
      'disabled': {
        $service_ensure = 'stopped'
        $service_enable = false
      }
      # make sure service is currently running, do not start it on boot
      'running': {
        $service_ensure = 'running'
        $service_enable = false
      }
      # do not start service on boot, do not care whether currently running
      # or not
      'unmanaged': {
        $service_ensure = undef
        $service_enable = false
      }
      # unknown status
      # note: don't forget to update the parameter check in init.pp if you
      #       add a new or change an existing status.
      default: {
        fail("\"${status}\" is an unknown service status value")
      }
    }

  # set params: removal
  } else {

    # make sure the service is stopped and disabled (the removal itself will be
    # done by package.pp)
    $service_ensure = 'stopped'
    $service_enable = false

  }

  $notify_service = $elasticsearch::restart_config_change ? {
    true  => Service["elasticsearch-instance-${name}"],
    false => undef,
  }


  if ( $status != 'unmanaged' and $ensure == 'present' ) {

    # defaults file content. Either from a hash or file
    if ($init_defaults_file != undef) {
      file { "${elasticsearch::params::defaults_location}/elasticsearch.${name}":
        ensure => $ensure,
        source => $init_defaults_file,
        owner  => 'root',
        group  => '0',
        mode   => '0644',
        before => Service["elasticsearch-instance-${name}"],
        notify => $notify_service,
      }

    } elsif ($init_defaults != undef and is_hash($init_defaults) ) {

      if(has_key($init_defaults, 'ES_USER')) {
        if($init_defaults['ES_USER'] != $elasticsearch::elasticsearch_user) {
          fail('Found ES_USER setting for init_defaults but is not same as elasticsearch_user setting. Please use elasticsearch_user setting.')
        }
      }

      $init_defaults_pre_hash = {
        'ES_USER' => $elasticsearch::elasticsearch_user,
        'ES_GROUP' => $elasticsearch::elasticsearch_group,
        'MAX_OPEN_FILES' => '65536',
      }
      $new_init_defaults = merge($init_defaults_pre_hash, $init_defaults)

      augeas { "defaults_${name}":
        incl    => "${elasticsearch::params::defaults_location}/elasticsearch.${name}",
        lens    => 'Shellvars.lns',
        changes => template("${module_name}/etc/sysconfig/defaults.erb"),
        before  => Service["elasticsearch-instance-${name}"],
        notify  => $notify_service,
      }

    }

    # init file from template
    if ($init_template != undef) {

      elasticsearch_service_file { "/etc/init.d/elasticsearch.${name}":
        ensure       => $ensure,
        content      => file($init_template),
        instance     => $name,
        notify       => $notify_service,
        package_name => $elasticsearch::package_name,
      }
      -> file { "/etc/init.d/elasticsearch.${name}":
        ensure => $ensure,
        owner  => 'root',
        group  => '0',
        mode   => '0755',
        before => Service["elasticsearch-instance-${name}"],
        notify => $notify_service,
      }

    }

  } elsif ($status != 'unmanaged') {

    file { "/etc/init.d/elasticsearch.${name}":
      ensure    => 'absent',
      subscribe => Service["elasticsearch-instance-${name}"],
    }

    file { "${elasticsearch::params::defaults_location}/elasticsearch.${name}":
      ensure    => 'absent',
      subscribe => Service["elasticsearch.${$name}"],
    }

  }


  if ( $status != 'unmanaged') {

    # action
    service { "elasticsearch-instance-${name}":
      ensure     => $service_ensure,
      enable     => $service_enable,
      name       => "elasticsearch.${name}",
      hasstatus  => $elasticsearch::params::service_hasstatus,
      hasrestart => $elasticsearch::params::service_hasrestart,
      pattern    => $elasticsearch::params::service_pattern,
    }

  }

}
