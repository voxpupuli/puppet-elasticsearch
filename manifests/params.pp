# == Class: elasticsearch::params
#
# This class exists to
# 1. Declutter the default value assignment for class parameters.
# 2. Manage internally used module variables in a central place.
#
# Therefore, many operating system dependent differences (names, paths, ...)
# are addressed in here.
#
#
# === Parameters
#
# This class does not provide any parameters.
#
#
# === Examples
#
# This class is not intended to be used directly.
#
#
# === Links
#
# * {Puppet Docs: Using Parameterized Classes}[http://j.mp/nVpyWY]
#
#
# === Authors
#
# * Richard Pijnenburg <mailto:richard@ispavailability.com>
#
class elasticsearch::params {

  #### Default values for the parameters of the main module class, init.pp

  # ensure
  $ensure = 'present'

  # autoupgrade
  $autoupgrade = false

  # restart on configuration change?
  $restart_on_change = true

  # service status
  $status = 'enabled'

  # configuration directory
  $confdir = '/etc/elasticsearch'

  # plugins directory
  $plugindir = '/usr/share/elasticsearch/plugins'

  # plugins helper binary
  $plugintool = '/usr/share/elasticsearch/bin/plugin'

  # default service settings
  $service_settings = {
    'ES_USER'      => 'elasticsearch',
    'ES_GROUP'     => 'elasticsearch',
  }

  #### Internal module values

  # packages
  case $::operatingsystem {
    'CentOS', 'Fedora', 'Scientific', 'RedHat', 'Amazon', 'OracleLinux': {
      # main application
      $package = [ 'elasticsearch' ]
    }
    'Debian', 'Ubuntu': {
      # main application
      $package = [ 'elasticsearch' ]
    }
    default: {
      fail("\"${module_name}\" provides no package default value
            for \"${::operatingsystem}\"")
    }
  }

  # service parameters
  case $::operatingsystem {
    'CentOS', 'Fedora', 'Scientific', 'RedHat', 'Amazon', 'OracleLinux': {
      $service_name          = 'elasticsearch'
      $service_hasrestart    = true
      $service_hasstatus     = true
      $service_pattern       = $service_name
      $service_provider      = 'redhat'
      $service_settings_path = "/etc/sysconfig/${service_name}"
    }
    'Debian', 'Ubuntu': {
      $service_name          = 'elasticsearch'
      $service_hasrestart    = true
      $service_hasstatus     = true
      $service_pattern       = $service_name
      $service_provider      = 'debian'
      $service_settings_path = "/etc/default/${service_name}"
    }
    default: {
      fail("\"${module_name}\" provides no service parameters
            for \"${::operatingsystem}\"")
    }
  }

}
