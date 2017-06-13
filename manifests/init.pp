# Top-level Elasticsearch class which may manage installation of the
# Elasticsearch package, package repository, java package, and other
# global options and parameters.
#
# @summary Manages the installation of Elasticsearch and related options.
#
# @example install Elasticsearch
#   class { 'elasticsearch': }
#
# @example removal and decommissioning
#   class { 'elasticsearch':
#     ensure => 'absent',
#   }
#
# @example install everything but disable service(s) afterwards
#   class { 'elasticsearch':
#     status => 'disabled',
#   }
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
# @param api_basic_auth_password [String]
#   Defines the default REST basic auth password for API authentication.
#
# @param api_basic_auth_username [String]
#   Defines the default REST basic auth username for API authentication.
#
# @param api_ca_file [String]
#   Path to a CA file which will be used to validate server certs when
#   communicating with the Elasticsearch API over HTTPS.
#
# @param api_ca_path [String]
#   Path to a directory with CA files which will be used to validate server
#   certs when communicating with the Elasticsearch API over HTTPS.
#
# @param api_host [String]
#   Default host to use when accessing Elasticsearch APIs.
#
# @param api_port [Integer]
#   Default port to use when accessing Elasticsearch APIs.
#
# @param api_protocol [String]
#   Default protocol to use when accessing Elasticsearch APIs.
#
# @param api_timeout [Integer]
#   Default timeout (in seconds) to use when accessing Elasticsearch APIs.
#
# @param autoupgrade [Boolean]
#   If set to `true`, any managed package will be upgraded on each Puppet run
#   when the package provider is able to find a newer version than the present
#   one. The exact behavior is provider dependent (see
#   {package, "upgradeable"}[http://j.mp/xbxmNP] in the Puppet documentation).
#
# @param config [Hash]
#   Elasticsearch configuration hash.
#
# @param config_hiera_merge [Boolean]
#   Enable Hiera merging for the config hash.
#
# @param configdir [String]
#   Directory containing the elasticsearch configuration.
#   Use this setting if your packages deviate from the norm (`/etc/elasticsearch`)
#
# @param daily_rolling_date_pattern [String]
#   File pattern for the file appender log when file_rolling_type is 'dailyRollingFile'.
#
# @param datadir [String]
#   Allows you to set the data directory of Elasticsearch.
#
# @param datadir_instance_directories [Boolean]
#   Control whether individual directories for instances will be created within
#   each instance's data directorry.
#
# @param default_logging_level [String]
#   Default logging level for Elasticsearch.
#
# @param elasticsearch_group [String]
#   The group Elasticsearch should run as. This also sets file group
#   permissions.
#
# @param elasticsearch_user [String]
#   The user Elasticsearch should run as. This also sets file ownership.
#
# @param file_rolling_type [String]
#   Configuration for the file appender rotation. It can be 'dailyRollingFile'
#   or 'rollingFile'. The first rotates by name, and the second one by size.
#
# @param indices [Hash]
#   Define indices via a hash. This is mainly used with Hiera's auto binding.
#
# @param indices_hiera_merge [Boolean]
#   Enable Hiera's merging function for indices.
#
# @param init_defaults [Hash]
#   Defaults file content in hash representation.
#
# @param init_defaults_file [String]
#   Defaults file as puppet resource.
#
# @param init_template [String]
#   Service file as a template.
#
# @param instances [Hash]
#   Define instances via a hash. This is mainly used with Hiera's auto binding.
#
# @param instances_hiera_merge [Boolean]
#   Enable Hiera's merging function for the instances.
#
# @param java_install [Boolean]
#   Install java which is required for Elasticsearch.
#
# @param java_package [String]
#   Custom java package to be used when managing Java with `java_install`.
#
# @param jvm_options [Array]
#   Array of options to set in jvm_options.
#
# @param logdir [String]
#   Directory that will be used for Elasticsearch logging.
#
# @param logging_config [Hash]
#   Representation of information to be included in the logging.yml file.
#
# @param logging_file [String]
#   Instead of a hash, you may supply a `puppet://` file source for the
#   logging.yml file.
#
# @param logging_template [String]
#   Use a custom logging template - just supply the relative path, i.e.
#   `$module/elasticsearch/logging.yml.erb`
#
# @param manage_repo [Boolean]
#   Enable repo management by enabling official Elastic repositories.
#
# @param package_dir [String]
#   Directory where packages are downloaded to.
#
# @param package_dl_timeout [Integer]
#   For http, https, and ftp downloads, you may set how long the exec resource
#   may take.
#
# @param package_name [String]
#   Name Of the package to install.
#
# @param package_pin [Boolean]
#   Enables package version pinning.
#   This pins the package version to the set version number and avoids
#   package upgrades.
#
# @param package_provider [String]
#   Method to install the packages, currently only `package` is supported.
#
# @param package_url [String]
#   URL of the package to download.
#   This can be an http, https, or ftp resource for remote packages, or a
#   `puppet://` resource or `file:/` for local packages
#
# @param pipelines [Hash]
#   Define pipelines via a hash. This is mainly used with Hiera's auto binding.
#
# @param pipelines_hiera_merge [Boolean]
#   Enable Hiera's merging function for pipelines.
#
# @param plugindir [String]
#   Directory containing elasticsearch plugins.
#   Use this setting if your packages deviate from the norm (/usr/share/elasticsearch/plugins)
#
# @param plugins [Hash]
#   Define plugins via a hash. This is mainly used with Hiera's auto binding.
#
# @param plugins_hiera_merge [Boolean]
#   Enable Hiera's merging function for the plugins.
#
# @param proxy_url [String]
#   For http and https downloads, you may set a proxy server to use. By default,
#   no proxy is used.
#   Format: `proto://[user:pass@]server[:port]/`
#
# @param purge_configdir [Boolean]
#   Purge the config directory of any unmanaged files.
#
# @param purge_package_dir [Boolean]
#   Purge package directory on removal
#
# @param purge_secrets [Boolean]
#   Whether or not keys present in the keystore will be removed if they are not
#   present in the specified secrets hash.
#
# @param repo_baseurl [String]
#   If a custom repository URL is needed (such as for installations behind
#   restrictive firewalls), this parameter overrides the upstream repository
#   URL. Note that any additional changes to the repository metdata (such as
#   signing keys and so on) will need to be handled appropriately.
#
# @param repo_key_id [String]
#   The apt GPG key id.
#
# @param repo_key_source [String]
#   URL of the repository GPG key.
#
# @param repo_priority [Integer]
#   Repository priority. yum and apt supported.
#
# @param repo_proxy [String]
#   URL for repository proxy.
#
# @param repo_stage [Boolean]
#   Use stdlib stage setup for managing the repo instead of anchoring.
#
# @param repo_version [String]
#   Elastic repositories are versioned per major version (0.90, 1.0). This
#   parameter controls which version to use.
#
# @param restart_on_change [Boolean]
#   Determines if the application should be automatically restarted
#   whenever the configuration, package, or plugins change. Enabling this
#   setting will cause Elasticsearch to restart whenever there is cause to
#   re-read configuration files, load new plugins, or start the service using an
#   updated/changed executable. This may be undesireable in highly available
#   environments. If all other restart_* parameters are left unset, the value of
#   `restart_on_change` is used for all other restart_*_change defaults.
#
# @param restart_config_change [Boolean]
#   Determines if the application should be automatically restarted
#   whenever the configuration changes. This includes the Elasticsearch
#   configuration file, any service files, and defaults files.
#   Disabling automatic restarts on config changes may be desired in an
#   environment where you need to ensure restarts occur in a controlled/rolling
#   manner rather than during a Puppet run.
#
# @param restart_package_change [Boolean]
#   Determines if the application should be automatically restarted
#   whenever the package (or package version) for Elasticsearch changes.
#   Disabling automatic restarts on package changes may be desired in an
#   environment where you need to ensure restarts occur in a controlled/rolling
#   manner rather than during a Puppet run.
#
# @param restart_plugin_change [Boolean]
#   Determines if the application should be automatically restarted whenever
#   plugins are installed or removed.
#   Disabling automatic restarts on plugin changes may be desired in an
#   environment where you need to ensure restarts occur in a controlled/rolling
#   manner rather than during a Puppet run.
#
# @param roles [Hash]
#   Define roles via a hash. This is mainly used with Hiera's auto binding.
#
# @param roles_hiera_merge [Boolean]
#   Enable Hiera's merging function for roles.
#
# @param rolling_file_max_backup_index [Integer]
#   Max number of logs to store whern file_rolling_type is 'rollingFile'
#
# @param rolling_file_max_file_size [String]
#   Max log file size when file_rolling_type is 'rollingFile'
#
# @param scripts [Hash]
#   Define scripts via a hash. This is mainly used with Hiera's auto binding.
#
# @param scripts_hiera_merge [Boolean]
#   Enable Hiera's merging function for scripts.
#
# @param secrets [Hash]
#   Optional default configuration hash of key/value pairs to store in the
#   Elasticsearch keystore file. If unset, the keystore is left unmanaged.
#
# @param security_logging_content [String]
#   File content for shield/x-pack logging configuration file (will be placed
#   into logging.yml or log4j2.properties file as appropriate).
#
# @param security_logging_source [String]
#   File source for shield/x-pack logging configuration file (will be placed
#   into logging.yml or log4j2.properties file as appropriate).
#
# @param security_plugin [String]
#   Which security plugin will be used to manage users, roles, and
#   certificates. Valid values are 'shield' and 'x-pack'.
#
# @param service_provider [String]
#   Service provider to use. By Default when a single service provider is
#   possible, that one is selected.
#
# @param status [String]
#   To define the status of the service. If set to `enabled`, the service will
#   be run and will be started at boot time. If set to `disabled`, the service
#   is stopped and will not be started at boot time. If set to `running`, the
#   service will be run but will not be started at boot time. You may use this
#   to start a service on the first Puppet run instead of the system startup.
#   If set to `unmanaged`, the service will not be started at boot time and Puppet
#   does not care whether the service is running or not. For example, this may
#   be useful if a cluster management software is used to decide when to start
#   the service plus assuring it is running on the desired node.
#
# @param system_key [String]
#   Source for the Shield/x-pack system key. Valid values are any that are
#   supported for the file resource `source` parameter.
#
# @param templates [Hash]
#   Define templates via a hash. This is mainly used with Hiera's auto binding.
#
# @param templates_hiera_merge [Boolean]
#   Enable Hiera's merging function for templates.
#
# @param users [Hash]
#   Define templates via a hash. This is mainly used with Hiera's auto binding.
#
# @param users_hiera_merge [Boolean]
#   Enable Hiera's merging function for users.
#
# @param validate_tls [Boolean]
#   Enable TLS/SSL validation on API calls.
#
# @param version [String]
#   To set the specific version you want to install.
#
# @author Richard Pijnenburg <richard.pijnenburg@elasticsearch.com>
# @author Tyler Langlois <tyler.langlois@elastic.co>
#
class elasticsearch(
  $ensure                         = 'present',
  $api_basic_auth_password        = undef,
  $api_basic_auth_username        = undef,
  $api_ca_file                    = undef,
  $api_ca_path                    = undef,
  $api_host                       = 'localhost',
  $api_port                       = 9200,
  $api_protocol                   = 'http',
  $api_timeout                    = 10,
  $autoupgrade                    = false,
  $config                         = undef,
  $config_hiera_merge             = false,
  $configdir                      = $elasticsearch::params::configdir,
  $daily_rolling_date_pattern     = '"\'.\'yyyy-MM-dd"',
  $datadir                        = $elasticsearch::params::datadir,
  $datadir_instance_directories   = true,
  $default_logging_level          = 'INFO',
  $elasticsearch_group            = $elasticsearch::params::elasticsearch_group,
  $elasticsearch_user             = $elasticsearch::params::elasticsearch_user,
  $file_rolling_type              = 'dailyRollingFile',
  $indices                        = undef,
  $indices_hiera_merge            = false,
  $init_defaults                  = undef,
  $init_defaults_file             = undef,
  $init_template                  = "${module_name}/etc/init.d/${elasticsearch::params::init_template}",
  $instances                      = undef,
  $instances_hiera_merge          = false,
  $java_install                   = false,
  $java_package                   = undef,
  $jvm_options                    = [],
  $logdir                         = '/var/log/elasticsearch',
  $logging_config                 = undef,
  $logging_file                   = undef,
  $logging_template               = undef,
  $manage_repo                    = false,
  $package_dir                    = $elasticsearch::params::package_dir,
  $package_dl_timeout             = 600,
  $package_name                   = $elasticsearch::params::package,
  $package_pin                    = true,
  $package_provider               = 'package',
  $package_url                    = undef,
  $pipelines                      = undef,
  $pipelines_hiera_merge          = false,
  $plugindir                      = $elasticsearch::params::plugindir,
  $plugins                        = undef,
  $plugins_hiera_merge            = false,
  $proxy_url                      = undef,
  $purge_configdir                = false,
  $purge_package_dir              = false,
  $purge_secrets                  = false,
  $repo_baseurl                   = undef,
  $repo_key_id                    = '46095ACC8548582C1A2699A9D27D666CD88E42B4',
  $repo_key_source                = 'https://artifacts.elastic.co/GPG-KEY-elasticsearch',
  $repo_priority                  = undef,
  $repo_proxy                     = undef,
  $repo_stage                     = false,
  $repo_version                   = undef,
  $restart_on_change              = $elasticsearch::params::restart_on_change,
  $restart_config_change          = $elasticsearch::restart_on_change,
  $restart_package_change         = $elasticsearch::restart_on_change,
  $restart_plugin_change          = $elasticsearch::restart_on_change,
  $roles                          = undef,
  $roles_hiera_merge              = false,
  $rolling_file_max_backup_index  = 1,
  $rolling_file_max_file_size     ='10MB',
  $scripts                        = undef,
  $scripts_hiera_merge            = false,
  $secrets                        = undef,
  $security_logging_content       = undef,
  $security_logging_source        = undef,
  $security_plugin                = undef,
  $service_provider               = 'init',
  $status                         = 'enabled',
  $system_key                     = undef,
  $templates                      = undef,
  $templates_hiera_merge          = false,
  $users                          = undef,
  $users_hiera_merge              = false,
  $validate_tls                   = true,
  $version                        = false,
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

    if ($secrets != undef) {
      validate_hash($secrets)
    }
  }

  # java install validation
  validate_bool($java_install)

  validate_bool(
    $datadir_instance_directories,
    $manage_repo,
    $package_pin
  )

  if ($manage_repo == true and $ensure == 'present') {
    if $repo_baseurl != undef {
      validate_string($repo_baseurl)
    } elsif $repo_version == undef {
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

  # Hiera support for indices
  validate_bool($indices_hiera_merge)

  if $indices_hiera_merge == true {
    $x_indices = hiera_hash('elasticsearch::indices', $::elasticsearch::indices)
  } else {
    $x_indices = $indices
  }

  if $x_indices {
    validate_hash($x_indices)
    create_resources('elasticsearch::index', $x_indices)
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

  # Hiera support for pipelines
  validate_bool($pipelines_hiera_merge)

  if $pipelines_hiera_merge == true {
    $x_pipelines = hiera_hash('elasticsearch::pipelines', $::elasticsearch::pipelines)
  } else {
    $x_pipelines = $pipelines
  }

  if $x_pipelines {
    validate_hash($x_pipelines)
    create_resources('elasticsearch::pipeline', $x_pipelines)
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

  # Hiera support for roles
  validate_bool($roles_hiera_merge)

  if $roles_hiera_merge == true {
    $x_roles = hiera_hash('elasticsearch::roles', $::elasticsearch::roles)
  } else {
    $x_roles = $roles
  }

  if $x_roles {
    validate_hash($x_roles)
    create_resources('elasticsearch::role', $x_roles)
  }

  # Hiera support for scripts
  validate_bool($scripts_hiera_merge)

  if $scripts_hiera_merge == true {
    $x_scripts = hiera_hash('elasticsearch::scripts', $::elasticsearch::scripts)
  } else {
    $x_scripts = $scripts
  }

  if $x_scripts {
    validate_hash($x_scripts)
    create_resources('elasticsearch::script', $x_scripts)
  }

  # Hiera support for templates
  validate_bool($templates_hiera_merge)

  if $templates_hiera_merge == true {
    $x_templates = hiera_hash('elasticsearch::templates', $::elasticsearch::templates)
  } else {
    $x_templates = $templates
  }

  if $x_templates {
    validate_hash($x_templates)
    create_resources('elasticsearch::template', $x_templates)
  }

  # Hiera support for users
  validate_bool($users_hiera_merge)

  if $users_hiera_merge == true {
    $x_users = hiera_hash('elasticsearch::users', $::elasticsearch::users)
  } else {
    $x_users = $users
  }

  if $x_users {
    validate_hash($x_users)
    create_resources('elasticsearch::user', $x_users)
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
