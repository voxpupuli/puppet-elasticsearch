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

  $settings = $elasticsearch::config

  $notify_elasticsearch = $elasticsearch::restart_on_change ? {
    true  => Class['elasticsearch::service'],
    false => undef,
  }

  file { '/etc/elasticsearch/elasticsearch.yml':
    ensure  => file,
    content => template("${module_name}/etc/elasticsearch/elasticsearch.yml.erb"),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Class['elasticsearch::package'],
    notify  => $notify_elasticsearch,
  }

}
