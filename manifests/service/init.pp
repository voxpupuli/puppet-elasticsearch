# == Define: elasticsearch::service::init
#
# This class exists to coordinate all service management related actions,
# functionality and logical units in a central place.
#
# <b>Note:</b> "service" is the Puppet term and type for background processes
# in general and is used in a platform-independent way. E.g. "service" means
# "daemon" in relation to Unix-like systems.
#
#
# === Parameters
#
# This class does not provide any parameters.
#
#
# === Examples
#
# === Authors
#
# * Richard Pijnenburg <mailto:richard@ispavailability.com>
#
define elasticsearch::service::init(
  $ensure             = $elasticsearch::ensure,
  $status             = $elasticsearch::status,
  $init_defaults_file = undef,
  $init_defaults      = undef,
  $init_template      = undef,
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

  $notify_service = $elasticsearch::restart_on_change ? {
    true  => Service[$name],
    false => undef,
  }


  if ( $status != 'unmanaged' ) {

    # defaults file content. Either from a hash or file
    if ($init_defaults_file != undef) {
      file { "${elasticsearch::params::defaults_location}/elasticsearch-${name}":
        ensure  => $ensure,
        source  => $init_defaults_file,
        owner   => 'root',
        group   => 'root',
        mode    => '0644',
        before  => Service[$name],
        notify  => $notify_service
      }

    } elsif ($init_defaults != undef and is_hash($init_defaults) ) {

      $init_defaults_pre_hash = { 'ES_USER' => $elasticsearch::elasticsearch_user, 'ES_GROUP' => $elasticsearch::elasticsearch_group }
      $new_init_defaults = merge($init_defaults_pre_hash, $init_defaults)

      augeas { "defaults_${name}":
        incl     => "${elasticsearch::params::defaults_location}/elasticsearch-${name}",
        lens     => 'Shellvars.lns',
        changes  => template("${module_name}/etc/sysconfig/defaults.erb"),
        before   => Service[$name],
        notify   => $notify_service
      }

    }

    # init file from template
    if ($init_template != undef) {

      file { "/etc/init.d/elasticsearch-${name}":
        ensure  => $ensure,
        content => template($init_template),
        owner   => 'root',
        group   => 'root',
        mode    => '0755',
        before  => Service[$name],
        notify  => $notify_service
      }

    }

  }

  # action
  service { $name:
    ensure     => $service_ensure,
    enable     => $service_enable,
    name       => "elasticsearch-${name}",
    hasstatus  => $elasticsearch::params::service_hasstatus,
    hasrestart => $elasticsearch::params::service_hasrestart,
    pattern    => $elasticsearch::params::service_pattern,
  }

}
