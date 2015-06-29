# == Define: elasticsearch::plugin
#
# This define allows you to install arbitrary Elasticsearch plugins
# either by using the default repositories or by specifying an URL
#
# All default values are defined in the elasticsearch::params class.
#
#
# === Parameters
#
# [*module_dir*]
#   Directory name where the module will be installed
#   Value type is string
#   Default value: None
#   This variable is deprecated
#
# [*ensure*]
#   Whether the plugin will be installed or removed.
#   Set to 'absent' to ensure a plugin is not installed
#   Value type is string
#   Default value: present
#   This variable is optional
#
# [*url*]
#   Specify an URL where to download the plugin from.
#   Value type is string
#   Default value: None
#   This variable is optional
#
# [*proxy_host*]
#   Proxy host to use when installing the plugin
#   Value type is string
#   Default value: None
#   This variable is optional
#
# [*proxy_port*]
#   Proxy port to use when installing the plugin
#   Value type is number
#   Default value: None
#   This variable is optional
#
# [*instances*]
#   Specify all the instances related
#   value type is string or array
#
# === Examples
#
# # From official repository
# elasticsearch::plugin{'mobz/elasticsearch-head': module_dir => 'head'}
#
# # From custom url
# elasticsearch::plugin{ 'elasticsearch-jetty':
#  module_dir => 'elasticsearch-jetty',
#  url        => 'https://oss-es-plugins.s3.amazonaws.com/elasticsearch-jetty/elasticsearch-jetty-0.90.0.zip',
# }
#
# === Authors
#
# * Matteo Sessa <mailto:matteo.sessa@catchoftheday.com.au>
# * Dennis Konert <mailto:dkonert@gmail.com>
# * Richard Pijnenburg <mailto:richard.pijnenburg@elasticsearch.com>
#
define elasticsearch::plugin(
    $instances,
    $module_dir  = undef,
    $ensure      = 'present',
    $url         = undef,
    $proxy_host  = undef,
    $proxy_port  = undef,
) {

  include elasticsearch

  Exec {
    path      => [ '/bin', '/usr/bin', '/usr/local/bin' ],
    cwd       => '/',
    user      => $elasticsearch::elasticsearch_user,
    tries     => 6,
    try_sleep => 10,
    timeout   => 600,
  }

  $notify_service = $elasticsearch::restart_on_change ? {
    false   => undef,
    default => Elasticsearch::Service[$instances],
  }

  if ($module_dir != undef) {
      warning("module_dir settings is deprecated for plugin ${name}. The directory is now auto detected.")
      $plugin_dir = $module_dir
  } else {
    $plugin_dir = plugin_dir($name)
  }

  # set proxy by override or parse and use proxy_url from
  # elasticsearch::proxy_url or use no proxy at all
  
  if ($proxy_host != undef and $proxy_port != undef) {
    $proxy = " -DproxyPort=${proxy_port} -DproxyHost=${proxy_host}"
  }
  elsif ($elasticsearch::proxy_url != undef) {
    $proxy_host_from_url = regsubst($elasticsearch::proxy_url, '(http|https)://([^:]+)(|:\d+).+', '\2')
    $proxy_port_from_url = regsubst($elasticsearch::proxy_url, '(http|https)://([^:]+)?(:(\d+)).+', '\4')
    
    # validate parsed values before using them
    if (is_string($proxy_host_from_url) and is_integer($proxy_port_from_url)) {
      $proxy = " -DproxyPort=${proxy_port_from_url} -DproxyHost=${proxy_host_from_url}"
    }
  }
  else {
    $proxy = '' # lint:ignore:empty_string_assignment
  }

  if ($url == undef) {
    $install_cmd = "${elasticsearch::plugintool}${proxy} -install ${name}"
    $exec_rets = [0,]
  } else {
    validate_string($url)
    $install_cmd = "${elasticsearch::plugintool}${proxy} -install ${name} -url ${url}"
    $exec_rets = [0,1]
  }

  case $ensure {
    'installed', 'present': {
      $name_file_path = "${elasticsearch::plugindir}/${plugin_dir}/.name"
      exec {"purge_plugin_${plugin_dir}_old":
        command => "${elasticsearch::plugintool} --remove ${plugin_dir}",
        onlyif  => "test -e ${elasticsearch::plugindir}/${plugin_dir} && test \"$(cat ${name_file_path})\" != '${name}'",
        before  => Exec["install_plugin_${name}"],
      }
      exec {"install_plugin_${name}":
        command => $install_cmd,
        creates => "${elasticsearch::plugindir}/${plugin_dir}",
        returns => $exec_rets,
        notify  => $notify_service,
        require => File[$elasticsearch::plugindir],
      }
      file {$name_file_path:
        ensure  => file,
        content => $name,
        require => Exec["install_plugin_${name}"],
      }
    }
    'absent': {
      exec {"remove_plugin_${name}":
        command => "${elasticsearch::plugintool} --remove ${plugin_dir}",
        onlyif  => "test -d ${elasticsearch::plugindir}/${plugin_dir}",
        notify  => $notify_service,
      }
    }
    default: {
      fail("${ensure} is not a valid ensure command.")
    }
  }
}
