# Top-level Elasticsearch class which may manage installation of the
# Elasticsearch package, package repository, and other
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
# @param ensure
#   Controls if the managed resources shall be `present` or `absent`.
#   If set to `absent`, the managed software packages will be uninstalled, and
#   any traces of the packages will be purged as well as possible, possibly
#   including existing configuration files.
#   System modifications (if any) will be reverted as well as possible (e.g.
#   removal of created users, services, changed log settings, and so on).
#   This is a destructive parameter and should be used with care.
#
# @param api_basic_auth_password
#   Defines the default REST basic auth password for API authentication.
#
# @param api_basic_auth_username
#   Defines the default REST basic auth username for API authentication.
#
# @param api_ca_file
#   Path to a CA file which will be used to validate server certs when
#   communicating with the Elasticsearch API over HTTPS.
#
# @param api_ca_path
#   Path to a directory with CA files which will be used to validate server
#   certs when communicating with the Elasticsearch API over HTTPS.
#
# @param api_host
#   Default host to use when accessing Elasticsearch APIs.
#
# @param api_port
#   Default port to use when accessing Elasticsearch APIs.
#
# @param api_protocol
#   Default protocol to use when accessing Elasticsearch APIs.
#
# @param api_timeout
#   Default timeout (in seconds) to use when accessing Elasticsearch APIs.
#
# @param autoupgrade
#   If set to `true`, any managed package will be upgraded on each Puppet run
#   when the package provider is able to find a newer version than the present
#   one. The exact behavior is provider dependent (see
#   {package, "upgradeable"}[http://j.mp/xbxmNP] in the Puppet documentation).
#
# @param config
#   Elasticsearch configuration hash.
#
# @param config_hiera_merge
#   Enable Hiera merging for the config hash.
#
# @param configdir
#   Directory containing the elasticsearch configuration.
#   Use this setting if your packages deviate from the norm (`/etc/elasticsearch`)
#
# @param daily_rolling_date_pattern
#   File pattern for the file appender log when file_rolling_type is 'dailyRollingFile'.
#
# @param datadir
#   Allows you to set the data directory of Elasticsearch.
#
# @param datadir_instance_directories
#   Control whether individual directories for instances will be created within
#   each instance's data directory.
#
# @param default_logging_level
#   Default logging level for Elasticsearch.
#
# @param defaults_location
#   Absolute path to directory containing init defaults file.
#
# @param download_tool
#   Command-line invocation with which to retrieve an optional package_url.
#
# @param elasticsearch_group
#   The group Elasticsearch should run as. This also sets file group
#   permissions.
#
# @param elasticsearch_user
#   The user Elasticsearch should run as. This also sets file ownership.
#
# @param file_rolling_type
#   Configuration for the file appender rotation. It can be 'dailyRollingFile'
#   or 'rollingFile'. The first rotates by name, and the second one by size.
#
# @param homedir
#   Directory where the elasticsearch installation's files are kept (plugins, etc.)
#
# @param indices
#   Define indices via a hash. This is mainly used with Hiera's auto binding.
#
# @param indices_hiera_merge
#   Enable Hiera's merging function for indices.
#
# @param init_defaults
#   Defaults file content in hash representation.
#
# @param init_defaults_file
#   Defaults file as puppet resource.
#
# @param init_template
#   Service file as a template.
#
# @param instances
#   Define instances via a hash. This is mainly used with Hiera's auto binding.
#
# @param instances_hiera_merge
#   Enable Hiera's merging function for the instances.
#
# @param jvm_options
#   Array of options to set in jvm_options.
#
# @param logdir
#   Directory that will be used for Elasticsearch logging.
#
# @param logging_config
#   Representation of information to be included in the logging.yml file.
#
# @param logging_file
#   Instead of a hash, you may supply a `puppet://` file source for the
#   logging.yml file.
#
# @param logging_template
#   Use a custom logging template - just supply the relative path, i.e.
#   `$module/elasticsearch/logging.yml.erb`
#
# @param manage_repo
#   Enable repo management by enabling official Elastic repositories.
#
# @param package_dir
#   Directory where packages are downloaded to.
#
# @param package_dl_timeout
#   For http, https, and ftp downloads, you may set how long the exec resource
#   may take.
#
# @param package_name
#   Name Of the package to install.
#
# @param package_provider
#   Method to install the packages, currently only `package` is supported.
#
# @param package_url
#   URL of the package to download.
#   This can be an http, https, or ftp resource for remote packages, or a
#   `puppet://` resource or `file:/` for local packages
#
# @param pid_dir
#   Directory where the elasticsearch process should write out its PID.
#
# @param pipelines
#   Define pipelines via a hash. This is mainly used with Hiera's auto binding.
#
# @param pipelines_hiera_merge
#   Enable Hiera's merging function for pipelines.
#
# @param plugindir
#   Directory containing elasticsearch plugins.
#   Use this setting if your packages deviate from the norm (/usr/share/elasticsearch/plugins)
#
# @param plugins
#   Define plugins via a hash. This is mainly used with Hiera's auto binding.
#
# @param plugins_hiera_merge
#   Enable Hiera's merging function for the plugins.
#
# @param proxy_url
#   For http and https downloads, you may set a proxy server to use. By default,
#   no proxy is used.
#   Format: `proto://[user:pass@]server[:port]/`
#
# @param purge_configdir
#   Purge the config directory of any unmanaged files.
#
# @param purge_package_dir
#   Purge package directory on removal
#
# @param purge_secrets
#   Whether or not keys present in the keystore will be removed if they are not
#   present in the specified secrets hash.
#
# @param repo_baseurl
#   If a custom repository URL is needed (such as for installations behind
#   restrictive firewalls), this parameter overrides the upstream repository
#   URL. Note that any additional changes to the repository metdata (such as
#   signing keys and so on) will need to be handled appropriately.
#
# @param repo_key_id
#   The apt GPG key id.
#
# @param repo_key_source
#   URL of the repository GPG key.
#
# @param repo_priority
#   Repository priority. yum and apt supported.
#
# @param repo_proxy
#   URL for repository proxy.
#
# @param repo_stage
#   Use stdlib stage setup for managing the repo instead of anchoring.
#
# @param repo_version
#   Elastic repositories are versioned per major version (5.x, 6.x). This
#   parameter controls which version to use.
#
# @param restart_on_change
#   Determines if the application should be automatically restarted
#   whenever the configuration, package, or plugins change. Enabling this
#   setting will cause Elasticsearch to restart whenever there is cause to
#   re-read configuration files, load new plugins, or start the service using an
#   updated/changed executable. This may be undesireable in highly available
#   environments. If all other restart_* parameters are left unset, the value of
#   `restart_on_change` is used for all other restart_*_change defaults.
#
# @param restart_config_change
#   Determines if the application should be automatically restarted
#   whenever the configuration changes. This includes the Elasticsearch
#   configuration file, any service files, and defaults files.
#   Disabling automatic restarts on config changes may be desired in an
#   environment where you need to ensure restarts occur in a controlled/rolling
#   manner rather than during a Puppet run.
#
# @param restart_package_change
#   Determines if the application should be automatically restarted
#   whenever the package (or package version) for Elasticsearch changes.
#   Disabling automatic restarts on package changes may be desired in an
#   environment where you need to ensure restarts occur in a controlled/rolling
#   manner rather than during a Puppet run.
#
# @param restart_plugin_change
#   Determines if the application should be automatically restarted whenever
#   plugins are installed or removed.
#   Disabling automatic restarts on plugin changes may be desired in an
#   environment where you need to ensure restarts occur in a controlled/rolling
#   manner rather than during a Puppet run.
#
# @param roles
#   Define roles via a hash. This is mainly used with Hiera's auto binding.
#
# @param roles_hiera_merge
#   Enable Hiera's merging function for roles.
#
# @param rolling_file_max_backup_index
#   Max number of logs to store whern file_rolling_type is 'rollingFile'
#
# @param rolling_file_max_file_size
#   Max log file size when file_rolling_type is 'rollingFile'
#
# @param scripts
#   Define scripts via a hash. This is mainly used with Hiera's auto binding.
#
# @param scripts_hiera_merge
#   Enable Hiera's merging function for scripts.
#
# @param secrets
#   Optional default configuration hash of key/value pairs to store in the
#   Elasticsearch keystore file. If unset, the keystore is left unmanaged.
#
# @param security_logging_content
#   File content for shield/x-pack logging configuration file (will be placed
#   into logging.yml or log4j2.properties file as appropriate).
#
# @param security_logging_source
#   File source for shield/x-pack logging configuration file (will be placed
#   into logging.yml or log4j2.properties file as appropriate).
#
# @param security_plugin
#   Which security plugin will be used to manage users, roles, and
#   certificates.
#
# @param service_provider
#   The service resource type provider to use when managing elasticsearch instances.
#
# @param status
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
# @param system_key
#   Source for the Shield/x-pack system key. Valid values are any that are
#   supported for the file resource `source` parameter.
#
# @param systemd_service_path
#   Path to the directory in which to install systemd service units.
#
# @param templates
#   Define templates via a hash. This is mainly used with Hiera's auto binding.
#
# @param templates_hiera_merge
#   Enable Hiera's merging function for templates.
#
# @param users
#   Define templates via a hash. This is mainly used with Hiera's auto binding.
#
# @param users_hiera_merge
#   Enable Hiera's merging function for users.
#
# @param validate_tls
#   Enable TLS/SSL validation on API calls.
#
# @param version
#   To set the specific version you want to install.
#
# @author Richard Pijnenburg <richard.pijnenburg@elasticsearch.com>
# @author Tyler Langlois <tyler.langlois@elastic.co>
#
class elasticsearch (
  Enum['absent', 'present']                    $ensure,
  Optional[String]                             $api_basic_auth_password,
  Optional[String]                             $api_basic_auth_username,
  Optional[String]                             $api_ca_file,
  Optional[String]                             $api_ca_path,
  String                                       $api_host,
  Tea::Port                                    $api_port,
  Enum['http', 'https']                        $api_protocol,
  Integer                                      $api_timeout,
  Boolean                                      $autoupgrade,
  Hash                                         $config,
  Boolean                                      $config_hiera_merge,
  Tea::Absolutepath                            $configdir,
  String                                       $daily_rolling_date_pattern,
  Elasticsearch::Multipath                     $datadir,
  Boolean                                      $datadir_instance_directories,
  String                                       $default_logging_level,
  Tea::Absolutepath                            $defaults_location,
  Optional[String]                             $download_tool,
  String                                       $elasticsearch_group,
  String                                       $elasticsearch_user,
  Enum['dailyRollingFile', 'rollingFile']      $file_rolling_type,
  Tea::Absolutepath                            $homedir,
  Optional[Hash]                               $indices,
  Boolean                                      $indices_hiera_merge,
  Hash                                         $init_defaults,
  Optional[String]                             $init_defaults_file,
  String                                       $init_template,
  Optional[Hash]                               $instances,
  Boolean                                      $instances_hiera_merge,
  Array[String]                                $jvm_options,
  Tea::Absolutepath                            $logdir,
  Hash                                         $logging_config,
  Optional[String]                             $logging_file,
  Optional[String]                             $logging_template,
  Boolean                                      $manage_repo,
  Tea::Absolutepath                            $package_dir,
  Integer                                      $package_dl_timeout,
  String                                       $package_name,
  Enum['package']                              $package_provider,
  Optional[String]                             $package_url,
  Optional[Tea::Absolutepath]                  $pid_dir,
  Optional[Hash]                               $pipelines,
  Boolean                                      $pipelines_hiera_merge,
  Tea::Absolutepath                            $plugindir,
  Optional[Hash]                               $plugins,
  Boolean                                      $plugins_hiera_merge,
  Optional[Tea::HTTPUrl]                       $proxy_url,
  Boolean                                      $purge_configdir,
  Boolean                                      $purge_package_dir,
  Boolean                                      $purge_secrets,
  Optional[String]                             $repo_baseurl,
  String                                       $repo_key_id,
  Tea::HTTPUrl                                 $repo_key_source,
  Optional[Integer]                            $repo_priority,
  Optional[String]                             $repo_proxy,
  Variant[Boolean, String]                     $repo_stage,
  String                                       $repo_version,
  Boolean                                      $restart_on_change,
  Optional[Hash]                               $roles,
  Boolean                                      $roles_hiera_merge,
  Integer                                      $rolling_file_max_backup_index,
  String                                       $rolling_file_max_file_size,
  Optional[Hash]                               $scripts,
  Boolean                                      $scripts_hiera_merge,
  Optional[Hash]                               $secrets,
  Optional[String]                             $security_logging_content,
  Optional[String]                             $security_logging_source,
  Optional[Enum['shield', 'x-pack']]           $security_plugin,
  Enum['init', 'openbsd', 'openrc', 'systemd'] $service_provider,
  Elasticsearch::Status                        $status,
  Optional[String]                             $system_key,
  Tea::Absolutepath                            $systemd_service_path,
  Optional[Hash]                               $templates,
  Boolean                                      $templates_hiera_merge,
  Optional[Hash]                               $users,
  Boolean                                      $users_hiera_merge,
  Boolean                                      $validate_tls,
  Variant[String, Boolean]                     $version,
  Boolean $restart_config_change  = $elasticsearch::restart_on_change,
  Boolean $restart_package_change = $elasticsearch::restart_on_change,
  Boolean $restart_plugin_change  = $elasticsearch::restart_on_change,
) {

  anchor {'elasticsearch::begin': }

  #### Validate parameters

  if ($package_url != undef and $version != false) {
    fail('Unable to set the version number when using package_url option.')
  }

  if ($version != false) {
    case $facts['os']['family'] {
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

  # This value serves as an unchanging default for platforms as a default for
  # init scripts to fallback on.
  $_datadir_default = $facts['kernel'] ? {
    'Linux'   => '/var/lib/elasticsearch',
    'OpenBSD' => '/var/elasticsearch/data',
    default   => undef,
  }

  #### Manage actions

  # package(s)
  class { 'elasticsearch::package': }

  # configuration
  class { 'elasticsearch::config': }

  if $config_hiera_merge == true {
    $x_config = hiera_hash('elasticsearch::config', $config)
  } else {
    $x_config = $config
  }

  # Hiera support for indices
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
  if $plugins_hiera_merge == true {
    $x_plugins = hiera_hash('elasticsearch::plugins', $::elasticsearch::plugins)
  } else {
    $x_plugins = $plugins
  }

  if $x_plugins {
    validate_hash($x_plugins)
    create_resources('elasticsearch::plugin', $x_plugins)
  }

  if $roles_hiera_merge == true {
    $x_roles = hiera_hash('elasticsearch::roles', $::elasticsearch::roles)
  } else {
    $x_roles = $roles
  }

  if $x_roles {
    validate_hash($x_roles)
    create_resources('elasticsearch::role', $x_roles)
  }

  if $scripts_hiera_merge == true {
    $x_scripts = hiera_hash('elasticsearch::scripts', $::elasticsearch::scripts)
  } else {
    $x_scripts = $scripts
  }

  if $x_scripts {
    validate_hash($x_scripts)
    create_resources('elasticsearch::script', $x_scripts)
  }

  if $templates_hiera_merge == true {
    $x_templates = hiera_hash('elasticsearch::templates', $::elasticsearch::templates)
  } else {
    $x_templates = $templates
  }

  if $x_templates {
    validate_hash($x_templates)
    create_resources('elasticsearch::template', $x_templates)
  }

  if $users_hiera_merge == true {
    $x_users = hiera_hash('elasticsearch::users', $::elasticsearch::users)
  } else {
    $x_users = $users
  }

  if $x_users {
    validate_hash($x_users)
    create_resources('elasticsearch::user', $x_users)
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

  if defined(Class['java']) { Class['java'] -> Class['elasticsearch::config'] }

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
