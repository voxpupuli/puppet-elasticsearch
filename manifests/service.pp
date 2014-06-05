# == Class: elasticsearch::service
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
# This class may be imported by other classes to use its functionality:
#   class { 'elasticsearch::service': }
#
# It is not intended to be used directly by external resources like node
# definitions or other modules.
#
#
# === Authors
#
# * Richard Pijnenburg <mailto:richard@ispavailability.com>
#
define elasticsearch::service(
  $ensure             = $elasticsearch::ensure,
  $status             = $elasticsearch::status,
  $init_defaults_file = undef,
  $init_defaults      = undef,
  $init_template      = undef,
) {

  case $elasticsearch::real_service_provider {

    init: {
      elasticsearch::service::init { $name:
        ensure             => $ensure,
        status             => $status,
        init_defaults_file => $init_defaults_file,
        init_defaults      => $init_defaults,
        init_template      => $init_template,
      }
    }
    systemd: {
      elasticsearch::service::systemd { $name:
        ensure             => $ensure,
        status             => $status,
        init_defaults_file => $init_defaults_file,
        init_defaults      => $init_defaults,
        init_template      => $init_template,
      }
    }
    default: {
      fail("Unknown service provider ${elasticsearch::real_service_provider}")
    }

  }

}
