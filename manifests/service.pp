# This class exists to coordinate all service management related actions,
# functionality and logical units in a central place.
#
# *Note*: "service" is the Puppet term and type for background processes
# in general and is used in a platform-independent way. E.g. "service" means
# "daemon" in relation to Unix-like systems.
#
# @author Richard Pijnenburg <richard.pijnenburg@elasticsearch.com>
# @author Tyler Langlois <tyler.langlois@elastic.co>
# @author Gavin Williams <gavin.williams@elastic.co>
#
class elasticsearch::service {
  #### Service management

  if $elasticsearch::ensure == 'present' {
    case $elasticsearch::status {
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
      default: {
      }
    }
  } else {
    # make sure the service is stopped and disabled (the removal itself will be
    # done by package.pp)
    $_service_ensure = 'stopped'
    $_service_enable = false
  }

  service { $elasticsearch::service_name:
    ensure => $_service_ensure,
    enable => $_service_enable,
  }
}
