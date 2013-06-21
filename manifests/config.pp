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

  include elasticsearch

  $settings = $elasticsearch::config

  $notify_elasticsearch = $elasticsearch::restart_on_change ? {
    true  => Class['elasticsearch::service'],
    false => undef,
  }

  file { $elasticsearch::confdir:
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  file { "${elasticsearch::confdir}/elasticsearch.yml":
    ensure  => file,
    content => template("${module_name}/etc/elasticsearch/elasticsearch.yml.erb"),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => [ Class['elasticsearch::package'], File[$elasticsearch::confdir] ],
    notify  => $notify_elasticsearch,
  }

  exec { 'mkdir_templates':
    command => "mkdir -p ${elasticsearch::confdir}/templates_import",
    cwd     => '/',
    creates => "${elasticsearch::confdir}/templates_import",
  }

}
