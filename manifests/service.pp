# This class exists to coordinate all service management related actions,
# functionality and logical units in a central place.
#
# *Note*: "service" is the Puppet term and type for background processes
# in general and is used in a platform-independent way. E.g. "service" means
# "daemon" in relation to Unix-like systems.
#
# @param ensure
#   Controls if the managed resources shall be `present` or `absent`.
#   If set to `absent`, the managed software packages will be uninstalled, and
#   any traces of the packages will be purged as well as possible, possibly
#   including existing configuration files.
#   System modifications (if any) will be reverted as well as possible (e.g.
#   removal of created users, services, changed log settings, and so on).
#   This is a destructive parameter and should be used with care.
#
# @param init_defaults
#   Defaults file content in hash representation
#
# @param init_defaults_file
#   Defaults file as puppet resource
#
# @param init_template
#   Service file as a template
#
# @param service_flags
#   Flags to pass to the service.
#
# @param status
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
# @author Gavin Williams <gavin.williams@elastic.co>
#
class elasticsearch::service {

  #### Service management

  if $::elasticsearch::ensure == 'present' {

    case $::elasticsearch::status {
      # make sure service is currently running, start it on boot
      'enabled': {
        $_service_ensure = 'running'
        $_service_enable = true
      }
      # make sure service is currently stopped, do not start it on boot
      'disabled': {
        $_service_ensure = 'stopped'
        $_service_enable = false
      }
      # make sure service is currently running, do not start it on boot
      'running': {
        $_service_ensure = 'running'
        $_service_enable = false
      }
      # do not start service on boot, do not care whether currently running
      # or not
      'unmanaged': {
        $_service_ensure = undef
        $_service_enable = false
      }
      default: { }
    }
  } else {
    # make sure the service is stopped and disabled (the removal itself will be
    # done by package.pp)
    $_service_ensure = 'stopped'
    $_service_enable = false
  }

  # # TODO: Flesh this out
  # $_service_require = undef

  # case $::elasticsearch::service_provider {
  #   'init': {

  #     $_service_provider = undef
  #   }
  #   'openbsd': {
  #     # include elasticsearch::service::openbsd
  #     $_service_provider = undef
  #   }
  #   'openrc': {
  #     # include elasticsearch::service::openrc
  #     $_service_provider = undef
  #   }
  #   'systemd': {
  #     # include elasticsearch::service::systemd
  #     $_service_provider = 'systemd'
  #   }
  #   default: {
  #     fail("Unknown service provider ${::elasticsearch::service_provider}")
  #   }
  # }

  service { $::elasticsearch::service_name:
    ensure  => $_service_ensure,
    enable  => $_service_enable,
    # provider => $_service_provider,
    require => $_service_require,
  }
}
