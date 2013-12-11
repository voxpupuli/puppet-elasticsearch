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
  $settings = $elasticsearch::_config
  $ports    = [9200, 9300]

  $notify_elasticsearch = $elasticsearch::restart_on_change ? {
    false   => undef,
    default => Class['elasticsearch::service'],
  }

  # Configuration
  file { $elasticsearch::conf_dir:
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  }

  file { "${elasticsearch::conf_dir}/templates_import":
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    require => File[$elasticsearch::conf_dir],
  }

  file { "${elasticsearch::conf_dir}/elasticsearch.yml":
    ensure  => file,
    content => template("${module_name}/etc/elasticsearch/elasticsearch.yml.erb"),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => [
      Class['elasticsearch::package'],
      File[$elasticsearch::conf_dir]
    ],
    notify  => $notify_elasticsearch,
  }

  $user = $elasticsearch::user
  $group = $elasticsearch::group

  # Data
  file { $elasticsearch::data_dir:
    ensure => directory,
    owner  => $user,
    group  => $group,
    mode   => '0755',
  }

  # Logs
  file { $elasticsearch::log_dir:
    ensure => directory,
    owner  => $user,
    group  => $group,
    mode   => '0755',
  }

  if $elasticsearch::manage_firewall {
    firewall { "101 allow elasticsearch ports:$ports":
      proto   => 'tcp',
      state   => ['NEW'],
      dport   => $ports,
      action  => 'accept',
      source  => $elasticsearch::firewall_subnet,
    } 
  }
}
