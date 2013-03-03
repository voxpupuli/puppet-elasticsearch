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

  if is_hash($settings) {
    $content = template("${module_name}/etc/elasticsearch/elasticsearch.yml.erb")
  } else {
    $content = $settings
  }

  if ($elasticsearch::restart_on_change) {
    File {
      notify => Class['elasticsearch::service']
    }
  }

  file { '/etc/elasticsearch/elasticsearch.yml':
    ensure  => file,
    content => $content,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Class['elasticsearch::package'],
  }

}
