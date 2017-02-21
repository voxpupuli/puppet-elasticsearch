# == Class: elasticsearch
#
# This class is able to install or remove elasticsearch on a node.
# It manages the status of the related service.
#
# === Parameters
#
# [*ensure*]
#   String. Controls if the managed resources shall be <tt>present</tt> or
#   <tt>absent</tt>. If set to <tt>absent</tt>:
#   * The managed software packages are being uninstalled.
#   * Any traces of the packages will be purged as good as possible. This may
#     include existing configuration files. The exact behavior is provider
#     dependent. Q.v.:
#     * Puppet type reference: {package, "purgeable"}[http://j.mp/xbxmNP]
#     * {Puppet's package provider source code}[http://j.mp/wtVCaL]
#   * System modifications (if any) will be reverted as good as possible
#     (e.g. removal of created users, services, changed log settings, ...).
#   * This is thus destructive and should be used with care.
#   Defaults to <tt>present</tt>.
#
# [*autoupgrade*]
#   Boolean. If set to <tt>true</tt>, any managed package gets upgraded
#   on each Puppet run when the package provider is able to find a newer
#   version than the present one. The exact behavior is provider dependent.
#   Q.v.:
#   * Puppet type reference: {package, "upgradeable"}[http://j.mp/xbxmNP]
#   * {Puppet's package provider source code}[http://j.mp/wtVCaL]
#   Defaults to <tt>false</tt>.
#
# [*status*]
#   String to define the status of the service. Possible values:
#   * <tt>enabled</tt>: Service is running and will be started at boot time.
#   * <tt>disabled</tt>: Service is stopped and will not be started at boot
#     time.
#   * <tt>running</tt>: Service is running but will not be started at boot time.
#     You can use this to start a service on the first Puppet run instead of
#     the system startup.
#   * <tt>unmanaged</tt>: Service will not be started at boot time and Puppet
#     does not care whether the service is running or not. For example, this may
#     be useful if a cluster management software is used to decide when to start
#     the service plus assuring it is running on the desired node.
#   Defaults to <tt>enabled</tt>. The singular form ("service") is used for the
#   sake of convenience. Of course, the defined status affects all services if
#   more than one is managed (see <tt>service.pp</tt> to check if this is the
#   case).
#
# [*version*]
#   String to set the specific version you want to install.
#   Defaults to <tt>false</tt>.
#
# [*restart_on_change*]
#   Boolean that determines if the application should be automatically restarted
#   whenever the configuration, package, or plugins change. Enabling this
#   setting will cause Elasticsearch to restart whenever there is cause to
#   re-read configuration files, load new plugins, or start the service using an
#   updated/changed executable. This may be undesireable in highly available
#   environments.
#
#   If all other restart_* parameters are left unset, the value of
#   restart_on_change is used for all other restart_*_change defaults.
#
#   Defaults to <tt>false</tt>, which disables automatic restarts. Setting to
#   <tt>true</tt> will restart the application on any config, plugin, or
#   package change.
#
# [*restart_config_change*]
#   Boolean that determines if the application should be automatically restarted
#   whenever the configuration changes. This includes the Elasticsearch
#   configuration file, any service files, and defaults files.
#   Disabling automatic restarts on config changes may be desired in an
#   environment where you need to ensure restarts occur in a controlled/rolling
#   manner rather than during a Puppet run.
#
#   Defaults to <tt>undef</tt>, in which case the default value of
#   restart_on_change will be used (defaults to false).
#
# [*restart_package_change*]
#   Boolean that determines if the application should be automatically restarted
#   whenever the package (or package version) for Elasticsearch changes.
#   Disabling automatic restarts on package changes may be desired in an
#   environment where you need to ensure restarts occur in a controlled/rolling
#   manner rather than during a Puppet run.
#
#   Defaults to <tt>undef</tt>, in which case the default value of
#   restart_on_change will be used (defaults to false).
#
# [*restart_plugin_change*]
#   Boolean that determines if the application should be automatically restarted
#   whenever plugins are installed or removed.
#   Disabling automatic restarts on plugin changes may be desired in an
#   environment where you need to ensure restarts occur in a controlled/rolling
#   manner rather than during a Puppet run.
#
#   Defaults to <tt>undef</tt>, in which case the default value of
#   restart_on_change will be used (defaults to false).
#
# [*configdir*]
#   Path to directory containing the elasticsearch configuration.
#   Use this setting if your packages deviate from the norm (/etc/elasticsearch)
#
# [*plugindir*]
#   Path to directory containing the elasticsearch plugins
#   Use this setting if your packages deviate from the norm (/usr/share/elasticsearch/plugins)
#
# [*package_url*]
#   Url to the package to download.
#   This can be a http,https or ftp resource for remote packages
#   puppet:// resource or file:/ for local packages
#
# [*package_provider*]
#   Way to install the packages, currently only packages are supported.
#
# [*package_dir*]
#   Directory where the packages are downloaded to
#
# [*package_name*]
#   Name of the package to install
#
# [*purge_package_dir*]
#   Purge package directory on removal
#
# [*package_dl_timeout*]
#   For http,https and ftp downloads you can set howlong the exec resource may take.
#   Defaults to: 600 seconds
#
# [*proxy_url*]
#   For http and https downloads you can set a proxy server to use
#   Format: proto://[user:pass@]server[:port]/
#   Defaults to: undef (proxy disabled)
#
# [*elasticsearch_user*]
#   The user Elasticsearch should run as. This also sets the file rights.
#
# [*elasticsearch_group*]
#   The group Elasticsearch should run as. This also sets the file rights
#
# [*purge_configdir*]
#   Purge the config directory for any unmanaged files
#
# [*service_provider*]
#   Service provider to use. By Default when a single service provider is possibe that one is selected.
#
# [*init_defaults*]
#   Defaults file content in hash representation
#
# [*init_defaults_file*]
#   Defaults file as puppet resource
#
# [*init_template*]
#   Service file as a template
#
# [*config*]
#   Elasticsearch configuration hash
#
# [*config_hiera_merge*]
#   Enable Hiera merging for the config hash
#   Defaults to: false
#
# [*datadir*]
#   Allows you to set the data directory of Elasticsearch
#
# [*logdir*]
#   Use different directory for logging
#
# [*java_install*]
#  Install java which is required for Elasticsearch.
#  Defaults to: false
#
# [*java_package*]
#   If you like to install a custom java package, put the name here.
#
# [*jvm_options*]
#   Array of options to set in jvm_options.
#   Value type is Array
#   Default value: []
#
# [*manage_repo*]
#   Enable repo management by enabling our official repositories
#
# [*repo_version*]
#   Our repositories are versioned per major version (0.90, 1.0) select here which version you want
#
# [*repo_priority*]
#   Repository priority. yum and apt supported.
#   Default: undef
#
# [*repo_key_id*]
#   String.  The apt GPG key id
#   Default: 46095ACC8548582C1A2699A9D27D666CD88E42B4
#
# [*repo_key_source*]
#   String.  URL of the apt GPG key
#   Default: http://packages.elastic.co/GPG-KEY-elasticsearch
#
# [*repo_proxy*]
#   String.  URL for repository proxy
#   Default: undef
#
# [*logging_config*]
#   Hash representation of information you want in the logging.yml file
#
# [*logging_file*]
#   Instead of a hash you can supply a puppet:// file source for the logging.yml file
#
# [*logging_template*]
#  Use a custom logging template - just supply the reative path ie ${module}/elasticsearch/logging.yml.erb
#
# [*default_logging_level*]
#   Default logging level for Elasticsearch.
#   Defaults to: INFO
#
# [*repo_stage*]
#   Use stdlib stage setup for managing the repo, instead of anchoring
#
# [*instances*]
#   Define instances via a hash. This is mainly used with Hiera's auto binding
#   Defaults to: undef
#
# [*instances_hiera_merge*]
#   Enable Hiera's merging function for the instances
#   Defaults to: false
#
# [*plugins*]
#   Define plugins via a hash. This is mainly used with Hiera's auto binding
#   Defaults to: undef
#
# [*plugins_hiera_merge*]
#   Enable Hiera's merging function for the plugins
#   Defaults to: false
#
# [*package_pin*]
#   Enables package version pinning.
#   This pins the package version to the set version number and avoids
#   package upgrades.
#   Defaults to: true
#
# [*api_protocol*]
#   Default protocol to use when accessing Elasticsearch APIs.
#   Defaults to: http
#
# [*api_host*]
#   Default host to use when accessing Elasticsearch APIs.
#   Defaults to: localhost
#
# [*api_port*]
#   Default port to use when accessing Elasticsearch APIs.
#   Defaults to: 9200
#
# [*api_timeout*]
#   Default timeout (in seconds) to use when accessing Elasticsearch APIs.
#   Defaults to: 10
#
# [*validate_tls*]
#   Enable TLS/SSL validation on API calls.
#   Defaults to: true
#
# [*api_basic_auth_username*]
#   Defines the default REST basic auth username for API authentication.
#   Defaults to: undef
#
# [*api_basic_auth_password*]
#   Defines the default REST basic auth password for API authentication.
#   Defaults to: undef
#
# [*api_ca_file*]
#   Path to a CA file which will be used to validate server certs when
#   communicating with the Elasticsearch API over HTTPS.
#   Defaults to: undef
#
# [*api_ca_path*]
#   Path to a directory with CA files which will be used to validate server
#   certs when communicating with the Elasticsearch API over HTTPS.
#   Defaults to: undef
#
# [*system_key*]
#   Source for the Shield/x-pack system key. Valid values are any that are
#   supported for the file resource `source` parameter.
#   Value type is string
#   Default value: undef
#
# [*file_rolling_type*]
#   Configuration for the file appender rotation. It can be 'dailyRollingFile'
#   or 'rollingFile'. The first rotates by name, and the second one by size.
#   Value type is string
#   Default value: dailyRollingFile
#
# [*daily_rolling_date_pattern*]
#   File pattern for the file appender log when file_rolling_type is 'dailyRollingFile'
#   Value type is string
#   Default value: "'.'yyyy-MM-dd"
#
# [*rolling_file_max_backup_index*]
#   Max number of logs to store whern file_rolling_type is 'rollingFile'
#   Value type is integer
#   Default value: 1
#
# [*rolling_file_max_file_size*]
#   Max log file size when file_rolling_type is 'rollingFile'
#   Value type is string
#   Default value: 10MB
#
# [*security_plugin*]
#   Which security plugin will be used to manage users, roles, and
#   certificates. Valid values are 'shield' and 'x-pack'
#   Value type is string
#   Default value: undef
#
# The default values for the parameters are set in elasticsearch::params. Have
# a look at the corresponding <tt>params.pp</tt> manifest file if you need more
# technical information about them.
#
# === Examples
#
# * Installation, make sure service is running and will be started at boot time:
#     class { 'elasticsearch': }
#
# * Removal/decommissioning:
#     class { 'elasticsearch':
#       ensure => 'absent',
#     }
#
# * Install everything but disable service(s) afterwards
#     class { 'elasticsearch':
#       status => 'disabled',
#     }
#
#
# === Authors
#
# * Richard Pijnenburg <mailto:richard.pijnenburg@elasticsearch.com>
#
class elasticsearch(
  $ensure                         = $elasticsearch::params::ensure,
  $status                         = $elasticsearch::params::status,
  $restart_on_change              = $elasticsearch::params::restart_on_change,
  $restart_config_change          = $elasticsearch::restart_on_change,
  $restart_package_change         = $elasticsearch::restart_on_change,
  $restart_plugin_change          = $elasticsearch::restart_on_change,
  $autoupgrade                    = $elasticsearch::params::autoupgrade,
  $version                        = false,
  $package_provider               = 'package',
  $package_url                    = undef,
  $package_dir                    = $elasticsearch::params::package_dir,
  $package_name                   = $elasticsearch::params::package,
  $package_pin                    = true,
  $purge_package_dir              = $elasticsearch::params::purge_package_dir,
  $package_dl_timeout             = $elasticsearch::params::package_dl_timeout,
  $proxy_url                      = undef,
  $elasticsearch_user             = $elasticsearch::params::elasticsearch_user,
  $elasticsearch_group            = $elasticsearch::params::elasticsearch_group,
  $configdir                      = $elasticsearch::params::configdir,
  $purge_configdir                = $elasticsearch::params::purge_configdir,
  $service_provider               = 'init',
  $init_defaults                  = undef,
  $init_defaults_file             = undef,
  $init_template                  = "${module_name}/etc/init.d/${elasticsearch::params::init_template}",
  $config                         = undef,
  $config_hiera_merge             = false,
  $datadir                        = $elasticsearch::params::datadir,
  $logdir                         = $elasticsearch::params::logdir,
  $plugindir                      = $elasticsearch::params::plugindir,
  $java_install                   = false,
  $java_package                   = undef,
  $jvm_options                    = [],
  $manage_repo                    = false,
  $repo_version                   = undef,
  $repo_priority                  = undef,
  $repo_key_id                    = '46095ACC8548582C1A2699A9D27D666CD88E42B4',
  $repo_key_source                = 'https://artifacts.elastic.co/GPG-KEY-elasticsearch',
  $repo_proxy                     = undef,
  $logging_file                   = undef,
  $logging_config                 = undef,
  $logging_template               = undef,
  $default_logging_level          = $elasticsearch::params::default_logging_level,
  $repo_stage                     = false,
  $instances                      = undef,
  $instances_hiera_merge          = false,
  $plugins                        = undef,
  $plugins_hiera_merge            = false,
  $api_protocol                   = 'http',
  $api_host                       = 'localhost',
  $api_port                       = 9200,
  $api_timeout                    = 10,
  $api_basic_auth_username        = undef,
  $api_basic_auth_password        = undef,
  $api_ca_file                    = undef,
  $api_ca_path                    = undef,
  $validate_tls                   = true,
  $system_key                     = undef,
  $file_rolling_type              = $elasticsearch::params::file_rolling_type,
  $daily_rolling_date_pattern     = $elasticsearch::params::daily_rolling_date_pattern,
  $rolling_file_max_backup_index  = $elasticsearch::params::rolling_file_max_backup_index,
  $rolling_file_max_file_size     = $elasticsearch::params::rolling_file_max_file_size,
  $security_plugin                = undef,
) inherits elasticsearch::params {

  anchor {'elasticsearch::begin': }


  #### Validate parameters

  # ensure
  if ! ($ensure in [ 'present', 'absent' ]) {
    fail("\"${ensure}\" is not a valid ensure parameter value")
  }

  # autoupgrade
  validate_bool($autoupgrade)

  # service status
  if ! ($status in [ 'enabled', 'disabled', 'running', 'unmanaged' ]) {
    fail("\"${status}\" is not a valid status parameter value")
  }

  if ! ($file_rolling_type in [ 'dailyRollingFile', 'rollingFile']) {
    fail("\"${file_rolling_type}\" is not a valid type")
  }

  validate_array($jvm_options)
  validate_integer($rolling_file_max_backup_index)
  validate_string($daily_rolling_date_pattern)
  validate_string($rolling_file_max_file_size)

  # restart on change
  validate_bool(
    $restart_on_change,
    $restart_config_change,
    $restart_package_change,
    $restart_plugin_change
  )

  # purge conf dir
  validate_bool($purge_configdir)

  if is_array($elasticsearch::params::service_providers) {
    # Verify the service provider given is in the array
    if ! ($service_provider in $elasticsearch::params::service_providers) {
      fail("\"${service_provider}\" is not a valid provider for \"${::operatingsystem}\"")
    }
    $real_service_provider = $service_provider
  } else {
    # There is only one option so simply set it
    $real_service_provider = $elasticsearch::params::service_providers
  }

  if ($package_url != undef and $version != false) {
    fail('Unable to set the version number when using package_url option.')
  }

  if $ensure == 'present' {
    # validate config hash
    if ($config != undef) {
      validate_hash($config)
    }

    if ($logging_config != undef) {
      validate_hash($logging_config)
    }
  }

  # java install validation
  validate_bool($java_install)

  validate_bool(
    $manage_repo,
    $package_pin
  )

  if ($manage_repo == true and $ensure == 'present') {
    if $repo_version == undef {
      fail('Please fill in a repository version at $repo_version')
    } else {
      validate_string($repo_version)
    }
  }

  if ($version != false) {
    case $::osfamily {
      'RedHat', 'Linux', 'Suse': {
        if ($version =~ /.+-\d/) {
          $pkg_version = $version
        } else {
          $pkg_version = "${version}-1"
        }
      }
      default: {
        $pkg_version = $version
      }
    }
  }

  # Various parameters governing API access to Elasticsearch
  validate_string($api_protocol, $api_host)
  validate_bool($validate_tls)
  if $api_basic_auth_username { validate_string($api_basic_auth_username) }
  if $api_basic_auth_password { validate_string($api_basic_auth_password) }

  if ! is_integer($api_timeout) {
    fail("'${api_timeout}' is not an integer")
  }

  if ! is_integer($api_port) {
    fail("'${api_port}' is not an integer")
  }

  if $system_key != undef { validate_string($system_key) }

  #### Manage actions

  # package(s)
  class { 'elasticsearch::package': }

  # configuration
  class { 'elasticsearch::config': }

  # Hiera support for configuration hash
  validate_bool($config_hiera_merge)

  if $config_hiera_merge == true {
    $x_config = hiera_hash('elasticsearch::config', $config)
  } else {
    $x_config = $config
  }

  # Hiera support for instances
  validate_bool($instances_hiera_merge)

  if $instances_hiera_merge == true {
    $x_instances = hiera_hash('elasticsearch::instances', $::elasticsearch::instances)
  } else {
    $x_instances = $instances
  }

  if $x_instances {
    validate_hash($x_instances)
    create_resources('elasticsearch::instance', $x_instances)
  }

  # Hiera support for plugins
  validate_bool($plugins_hiera_merge)

  if $plugins_hiera_merge == true {
    $x_plugins = hiera_hash('elasticsearch::plugins', $::elasticsearch::plugins)
  } else {
    $x_plugins = $plugins
  }

  if $x_plugins {
    validate_hash($x_plugins)
    create_resources('elasticsearch::plugin', $x_plugins)
  }


  if $java_install == true {
    # Install java
    class { '::java':
      package      => $java_package,
      distribution => 'jre',
    }

    # ensure we first install java, the package and then the rest
    Anchor['elasticsearch::begin']
    -> Class['::java']
    -> Class['elasticsearch::package']
  }

  if $package_pin {
    class { 'elasticsearch::package::pin':
      before => Class['elasticsearch::package'],
    }
  }

  if ($manage_repo == true) {

    if ($repo_stage == false) {
      # use anchor for ordering

      # Set up repositories
      class { 'elasticsearch::repo': }

      # Ensure that we set up the repositories before trying to install
      # the packages
      Anchor['elasticsearch::begin']
      -> Class['elasticsearch::repo']
      -> Class['elasticsearch::package']

    } else {
      # use staging for ordering

      if !(defined(Stage[$repo_stage])) {
        stage { $repo_stage:  before => Stage['main'] }
      }

      class { 'elasticsearch::repo':
        stage => $repo_stage,
      }
    }

  }

  #### Manage relationships
  #
  # Note that many of these overly verbose declarations work around
  # https://tickets.puppetlabs.com/browse/PUP-1410
  # which means clean arrow order chaining won't work if someone, say,
  # doesn't declare any plugins.
  #
  # forgive me for what you're about to see

  if $ensure == 'present' {

    # Anchor, installation, and configuration
    Anchor['elasticsearch::begin']
    -> Class['elasticsearch::package']
    -> Class['elasticsearch::config']

    # Top-level ordering bindings for resources.
    Class['elasticsearch::config']
    -> Elasticsearch::Plugin <| ensure == 'present' or ensure == 'installed' |>
    Elasticsearch::Plugin <| ensure == 'absent' |>
    -> Class['elasticsearch::config']
    Class['elasticsearch::config']
    -> Elasticsearch::Instance <| |>
    Class['elasticsearch::config']
    -> Elasticsearch::User <| |>
    Class['elasticsearch::config']
    -> Elasticsearch::Role <| |>
    Class['elasticsearch::config']
    -> Elasticsearch::Template <| |>
    Class['elasticsearch::config']
    -> Elasticsearch::Pipeline <| |>
    Class['elasticsearch::config']
    -> Elasticsearch::Index <| |>

  } else {

    # Main anchor and included classes
    Anchor['elasticsearch::begin']
    -> Class['elasticsearch::config']
    -> Class['elasticsearch::package']

    # Top-level ordering bindings for resources.
    Anchor['elasticsearch::begin']
    -> Elasticsearch::Plugin <| |>
    -> Class['elasticsearch::config']
    Anchor['elasticsearch::begin']
    -> Elasticsearch::Instance <| |>
    -> Class['elasticsearch::config']
    Anchor['elasticsearch::begin']
    -> Elasticsearch::User <| |>
    -> Class['elasticsearch::config']
    Anchor['elasticsearch::begin']
    -> Elasticsearch::Role <| |>
    -> Class['elasticsearch::config']
    Anchor['elasticsearch::begin']
    -> Elasticsearch::Template <| |>
    -> Class['elasticsearch::config']
    Anchor['elasticsearch::begin']
    -> Elasticsearch::Pipeline <| |>
    -> Class['elasticsearch::config']
    Anchor['elasticsearch::begin']
    -> Elasticsearch::Index <| |>
    -> Class['elasticsearch::config']

  }

  # Install plugins before managing instances or users/roles
  Elasticsearch::Plugin <| ensure == 'present' or ensure == 'installed' |>
  -> Elasticsearch::Instance <| |>
  Elasticsearch::Plugin <| ensure == 'present' or ensure == 'installed' |>
  -> Elasticsearch::User <| |>
  Elasticsearch::Plugin <| ensure == 'present' or ensure == 'installed' |>
  -> Elasticsearch::Role <| |>

  # Remove plugins after managing users/roles
  Elasticsearch::User <| |>
  -> Elasticsearch::Plugin <| ensure == 'absent' |>
  Elasticsearch::Role <| |>
  -> Elasticsearch::Plugin <| ensure == 'absent' |>

  # Ensure roles are defined before managing users that reference roles
  Elasticsearch::Role <| |>
  -> Elasticsearch::User <| ensure == 'present' |>
  # Ensure users are removed before referenced roles are managed
  Elasticsearch::User <| ensure == 'absent' |>
  -> Elasticsearch::Role <| |>

  # Ensure users and roles are managed before calling out to REST resources
  Elasticsearch::Role <| |>
  -> Elasticsearch::Template <| |>
  Elasticsearch::User <| |>
  -> Elasticsearch::Template <| |>
  Elasticsearch::Role <| |>
  -> Elasticsearch::Pipeline <| |>
  Elasticsearch::User <| |>
  -> Elasticsearch::Pipeline <| |>
  Elasticsearch::Role <| |>
  -> Elasticsearch::Index <| |>
  Elasticsearch::User <| |>
  -> Elasticsearch::Index <| |>

  # Manage users/roles before instances (req'd to keep dir in sync)
  Elasticsearch::Role <| |>
  -> Elasticsearch::Instance <| |>
  Elasticsearch::User <| |>
  -> Elasticsearch::Instance <| |>

  # Ensure instances are started before managing REST resources
  Elasticsearch::Instance <| ensure == 'present' |>
  -> Elasticsearch::Template <| |>
  Elasticsearch::Instance <| ensure == 'present' |>
  -> Elasticsearch::Pipeline <| |>
  Elasticsearch::Instance <| ensure == 'present' |>
  -> Elasticsearch::Index <| |>
  # Ensure instances are stopped after managing REST resources
  Elasticsearch::Template <| |>
  -> Elasticsearch::Instance <| ensure == 'absent' |>
  Elasticsearch::Pipeline <| |>
  -> Elasticsearch::Instance <| ensure == 'absent' |>
  Elasticsearch::Index <| |>
  -> Elasticsearch::Instance <| ensure == 'absent' |>
}
