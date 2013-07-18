# == Class: elasticsearch::package
#
# This class exists to coordinate all software package management related
# actions, functionality and logical units in a central place.
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
#   class { 'elasticsearch::package': }
#
# It is not intended to be used directly by external resources like node
# definitions or other modules.
#
#
# === Authors
#
# * Richard Pijnenburg <mailto:richard@ispavailability.com>
#
class elasticsearch::package {

  #### Package management

  # set params: in operation
  if $elasticsearch::ensure == 'present' {

    if $elasticsearch::version == false {

      $package_ensure = $elasticsearch::autoupgrade ? {
        true  => 'latest',
        false => 'present',
      }

    }  else {

      $package_ensure = $elasticsearch::version

    }

  # set params: removal
  } else {
    $package_ensure = 'purged'
  }

  # if a pkg_source isn't specified, get the right version
  # https://gist.github.com/wingdspur/2026107
  if $elasticsearch::pkg_source {
    $pkg_source = $elasticsearch::pkg_source
  } else {
    $pkg_dir = "/tmp"
    case $elasticsearch::params::service_provider {
      "redhat": { $pkg_ext = "rpm" }
      "debian": { $pkg_ext = "deb" }
      default:  { fail("Unknown service_provider") }
    }
    $pkg_filename = "elasticsearch-${::es_version}.${pkg_ext}"
    $pkg_source = "${pkg_dir}/${pkg_filename}"
    exec { "wget ${pkg_filename}":
      command => "wget https://download.elasticsearch.org/elasticsearch/elasticsearch/${pkg_filename}",
      cwd     => "${pkg_dir}",
      path    => ["/usr/bin"],
      creates => $pkg_source
    }
  }
  
  $filenameArray = split($pkg_source, '/')
  $basefilename = $filenameArray[-1]

  $extArray = split($basefilename, '\.')
  $ext = $extArray[-1]
  
  $tmpSource = "${pkg_dir}/${basefilename}"

  file { $tmpSource:
    source => $pkg_source,
    owner  => 'root',
    group  => 'root',
    require => Exec["wget ${pkg_filename}"],
    backup => false
  }

  case $ext {
    'deb':   { $pkg_provider = 'dpkg' }
    'rpm':   { $pkg_provider = 'rpm'  }
    default: { fail("Unknown file extention \"${ext}\"") }
  }

  # quick 'n dirty check to see if elasticsearch has java
  exec { "java-test":
    logoutput => on_failure,
    command   => "echo 'java not installed. try setting java_install=true' && exit 1",
    unless    => "which java",
    path      => ["/usr/bin", "/bin"],
  }
  
  # action
  package { $elasticsearch::params::package:
    ensure   => $package_ensure,
    source   => $tmpSource,
    require  => Exec["java-test"],
    provider => $pkg_provider
  }

}
