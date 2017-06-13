# There are many python bindings for elasticsearch. This provides all
# the ones we know about http://www.elasticsearch.org/guide/clients/
#
# @example installing the pyes python Elasticsearch library
#   elasticsearch::python { 'pyes':; }
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
define elasticsearch::python (
  $ensure = 'present'
) {

  if ! ($ensure in [ 'present', 'absent' ]) {
    fail("\"${ensure}\" is not a valid ensure parameter value")
  }

  # make sure the package name is valid and setup the provider as
  # necessary
  case $name {
    'pyes': {
      $provider = 'pip'
    }
    'rawes': {
      $provider = 'pip'
    }
    'pyelasticsearch': {
      $provider = 'pip'
    }
    'ESClient': {
      $provider = 'pip'
    }
    'elasticutils': {
      $provider = 'pip'
    }
    'elasticsearch': {
      $provider = 'pip'
    }
    default: {
      fail("unknown python binding package '${name}'")
    }
  }

  package { "python_${name}":
    ensure   => $ensure,
    name     => $name,
    provider => $provider,
  }

}
