# This define allows you to install arbitrary Elasticsearch plugins
# either by using the default repositories or by specifying an URL
#
# All default values are defined in the elasticsearch::params class.
#
# @example install from official repository
#   elasticsearch::plugin {'mobz/elasticsearch-head': module_dir => 'head'}
#
# @example installation using a custom URL
#   elasticsearch::plugin { 'elasticsearch-jetty':
#    module_dir => 'elasticsearch-jetty',
#    url        => 'https://oss-es-plugins.s3.amazonaws.com/elasticsearch-jetty/elasticsearch-jetty-0.90.0.zip',
#   }
#
# @param ensure [String]
#   Whether the plugin will be installed or removed.
#   Set to 'absent' to ensure a plugin is not installed
#
# @param instances [Enum[String, Array]]
#   Specify all the instances related
#
# @param module_dir [String]
#   Directory name where the module has been installed
#   This is automatically generated based on the module name
#   Specify a value here to override the auto generated value
#
# @param proxy_host [String]
#   Proxy host to use when installing the plugin
#
# @param proxy_password [String]
#   Proxy auth password to use when installing the plugin
#
# @param proxy_port [Integer]
#   Proxy port to use when installing the plugin
#
# @param proxy_username [String]
#   Proxy auth username to use when installing the plugin
#
# @param source [String]
#   Specify the source of the plugin.
#   This will copy over the plugin to the node and use it for installation.
#   Useful for offline installation
#
# @param url [String]
#   Specify an URL where to download the plugin from.
#
# @author Richard Pijnenburg <richard.pijnenburg@elasticsearch.com>
# @author Matteo Sessa <matteo.sessa@catchoftheday.com.au>
# @author Dennis Konert <dkonert@gmail.com>
# @author Tyler Langlois <tyler.langlois@elastic.co>
#
define elasticsearch::plugin (
  $ensure         = 'present',
  $instances      = undef,
  $module_dir     = undef,
  $proxy_host     = undef,
  $proxy_password = undef,
  $proxy_port     = undef,
  $proxy_username = undef,
  $source         = undef,
  $url            = undef,
) {

  include elasticsearch

  case $ensure {
    'installed', 'present': {
      if empty($instances) and $elasticsearch::restart_plugin_change {
        fail('no $instances defined, even tho `restart_plugin_change` is set!')
      }

      $_file_ensure = 'directory'
      $_file_before = []
    }
    'absent': {
      $_file_ensure = $ensure
      $_file_before = File[$elasticsearch::plugindir]
    }
    default: {
      fail("'${ensure}' is not a valid ensure parameter value")
    }
  }

  if ! empty($instances) and $elasticsearch::restart_plugin_change {
    Elasticsearch_plugin[$name] {
      notify +> Elasticsearch::Instance[$instances],
    }
  }

  # set proxy by override or parse and use proxy_url from
  # elasticsearch::proxy_url or use no proxy at all

  if ($proxy_host != undef and $proxy_port != undef) {
    if ($proxy_username != undef and $proxy_password != undef) {
      $_proxy_auth = "${proxy_username}:${proxy_password}@"
    } else {
      $_proxy_auth = undef
    }
    $_proxy = "http://${_proxy_auth}${proxy_host}:${proxy_port}"
  } elsif ($elasticsearch::proxy_url != undef) {
    $_proxy = $elasticsearch::proxy_url
  } else {
    $_proxy = undef
  }

  if ($source != undef) {

    $filename_array = split($source, '/')
    $basefilename = $filename_array[-1]

    $file_source = "${elasticsearch::package_dir}/${basefilename}"

    file { $file_source:
      ensure => 'file',
      source => $source,
      before => Elasticsearch_plugin[$name],
    }

  } else {
    $file_source = undef
  }

  if ($url != undef) {
    validate_string($url)
  }

  $_module_dir = es_plugin_name($module_dir, $name)

  elasticsearch_plugin { $name:
    ensure                     => $ensure,
    elasticsearch_package_name => $elasticsearch::package_name,
    source                     => $file_source,
    url                        => $url,
    proxy                      => $_proxy,
    plugin_dir                 => $::elasticsearch::plugindir,
    plugin_path                => $module_dir,
  }
  -> file { "${elasticsearch::plugindir}/${_module_dir}":
    ensure  => $_file_ensure,
    mode    => 'o+Xr',
    recurse => true,
    before  => $_file_before,
  }
}
