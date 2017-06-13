# == Define: elasticsearch::script
#
#  This define allows you to insert, update or delete scripts that are used within Elasticsearch
#
# === Parameters
#
# [*ensure*]
#   Controls the state of the script file resource to manage.
#   Values are simply passed through to the `file` resource.
#   Value type is string
#   Default value: present
#
# [*source*]
#   Puppet source of the script
#   Value type is string
#   Default value: undef
#   This variable is mandatory
#
# [*recurse*]
#   `recurse` parameter that will be passed through to the script file
#   resource.
#   Default value: undef
#
# === Authors
#
# * Richard Pijnenburg <mailto:richard.pijnenburg@elasticsearch.com>
# * Tyler Langlois <mailto:tyler@elastic.co>
#
define elasticsearch::script (
  $source,
  $ensure  = 'present',
  $recurse = undef,
) {

  require elasticsearch

  $filename_array = split($source, '/')
  $basefilename = $filename_array[-1]

  file { "${elasticsearch::params::homedir}/scripts/${basefilename}":
    ensure  => $ensure,
    source  => $source,
    owner   => $elasticsearch::elasticsearch_user,
    group   => $elasticsearch::elasticsearch_group,
    recurse => $recurse,
    mode    => '0644',
  }
}
