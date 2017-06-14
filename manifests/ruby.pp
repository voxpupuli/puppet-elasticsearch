# There are many ruby bindings for elasticsearch; this provides all
# the ones we know about: http://www.elasticsearch.org/guide/clients/
#
# @example install the elasticsearch ruby library
#   elasticsearch::ruby { 'elasticsearch': }
#
# @param ensure [String]
#   Controls if the managed resources shall be `present` or `absent`.
#   If set to `absent`, the managed software packages will be uninstalled, and
#   any traces of the packages will be purged as well as possible, possibly
#   including existing configuration files.
#   System modifications (if any) will be reverted as well as possible (e.g.
#   removal of created users, services, changed log settings, and so on).
#   This is a destructive parameter and should be used with care.
#
# @author Richard Pijnenburg <richard.pijnenburg@elasticsearch.com>
# @author Tyler Langlois <tyler.langlois@elastic.co>
#
define elasticsearch::ruby (
  $ensure = 'present'
) {

  if ! ($ensure in [ 'present', 'absent' ]) {
    fail("\"${ensure}\" is not a valid ensure parameter value")
  }

  # make sure the package name is valid and setup the provider as
  # necessary
  case $name {
    'tire': {
      $provider = 'gem'
    }
    'stretcher': {
      $provider = 'gem'
    }
    'elastic_searchable': {
      $provider = 'gem'
    }
    'elasticsearch': {
      $provider = 'gem'
    }
    'flex': {
      $provider = 'gem'
    }
    default: {
      fail("unknown ruby client package '${name}'")
    }
  }

  package { "ruby_${name}":
    ensure   => $ensure,
    name     => $name,
    provider => $provider,
  }

}
