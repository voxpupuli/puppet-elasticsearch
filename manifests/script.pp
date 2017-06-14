#  This define allows you to insert, update or delete scripts that are used
#  within Elasticsearch.
#
# @param ensure [String]
#   Controls the state of the script file resource to manage.
#   Values are simply passed through to the `file` resource.
#
# @param recurse [Enum[String, Boolean]]
#   Will be passed through to the script file resource.
#
# @param source [String]
#   Puppet source of the script
#
# @author Richard Pijnenburg <richard.pijnenburg@elasticsearch.com>
# @author Tyler Langlois <tyler.langlois@elastic.co>
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
