# there are many python bindings for elasticsearch. This provides all
# the ones we know about http://www.elasticsearch.org/guide/clients/
class elasticsearch::python (
  $pkg_name = "rawes",
  $ensure   = "installed",
) {

  # make sure the package name is valid and setup the provider as
  # necessary
  case $pkg_name {
    "pyes": {
      $provider => "pip"
    }
    "rawes": {
      $provider => "pip"
    }
    "pyelasticsearch": {
      $provider => "pip"
    }
    "ESClient": {
      $provider => "pip"
    }
    "elasticutils": {
      $provider => "pip"
    }
    default: {
      fail("unknown python binding package '${pkgname}'")
    }
  }

  package { $pkg_name:
    ensure => $ensure,
    provider => $provider,
  }
}
