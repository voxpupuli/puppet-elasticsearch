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
# @param ca_certificate
#   Path to the trusted CA certificate to add to this node's Java keystore.
#
# @param certificate
#   Path to the certificate for this node signed by the CA listed in
#   ca_certificate.
#
# @param config
#   Elasticsearch configuration hash.
#
# @param configdir
#   Directory containing the elasticsearch configuration.
#   Use this setting if your packages deviate from the norm (`/etc/elasticsearch`)
#
# @param configdir_recurselimit
#   Dictates how deeply the file copy recursion logic should descend when
#   copying files from the `configdir` to instance `configdir`s.
#
# @param datadir
#   Allows you to set the data directory of Elasticsearch.
#
# @param defaults_location
#   Absolute path to directory containing init defaults file.
#
# @param download_tool
#   Command-line invocation with which to retrieve an optional package_url.
#
# @param download_tool_insecure
#   Command-line invocation with which to retrieve an optional package_url when
#   certificate verification should be ignored.
#
# @param download_tool_verify_certificates
#   Whether or not to verify SSL/TLS certificates when retrieving package files
#   using a download tool instead of a package management provider.
#
# @param elasticsearch_group
#   The group Elasticsearch should run as. This also sets file group
#   permissions.
#
# @param elasticsearch_user
#   The user Elasticsearch should run as. This also sets file ownership.
#
# @param homedir
#   Directory where the elasticsearch installation's files are kept (plugins, etc.)
#
# @param indices
#   Define indices via a hash. This is mainly used with Hiera's auto binding.
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
# @param jvm_options
#   Array of options to set in jvm_options.
#
# @param keystore_password
#   Password to encrypt this node's Java keystore.
#
# @param keystore_path
#   Custom path to the Java keystore file. This parameter is optional.
#
# @param license
#   Optional Elasticsearch license in hash or string form.
#
# @param logdir
#   Directory that will be used for Elasticsearch logging.
#
# @param logdir_mode
#   Mode directory that will be used for Elasticsearch logging (default 2750).
#
# @param logging_content
#   Content to use for the logging configuration file (log4j2.properties).
#
# @param manage_datadir
#   Enable datadir management (default true).
#
# @param manage_logdir
#   Enable logdir management (default true).
#
# @param manage_repo
#   Enable repo management by enabling official Elastic repositories.
#
# @param oss
#   Whether to use the purely open source Elasticsearch package distribution.
#
# @param package_dir
#   Directory where packages are downloaded to.
#
# @param package_dl_timeout
#   For http, https, and ftp downloads, you may set how long the exec resource
#   may take.
#
# @param package_hold
#   Set to hold to tell Debian apt/Solaris pkg to hold the package version.
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
# @param plugindir
#   Directory containing elasticsearch plugins.
#   Use this setting if your packages deviate from the norm (/usr/share/elasticsearch/plugins)
#
# @param plugins
#   Define plugins via a hash. This is mainly used with Hiera's auto binding.
#
# @param private_key
#   Path to the key associated with this node's certificate.
#
# @param private_key_type
#   The type of the private key. Usually the private key is of type RSA key but it can also be an Elliptic Curve key (EC) or DSA.
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
# @param repo_stage
#   Use stdlib stage setup for managing the repo instead of relationship
#   ordering.
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
# @param scripts
#   Define scripts via a hash. This is mainly used with Hiera's auto binding.
#
# @param secrets
#   Optional default configuration hash of key/value pairs to store in the
#   Elasticsearch keystore file. If unset, the keystore is left unmanaged.
#
# @param service_name
#   Elasticsearch service name
#
# @param service_provider
#   The service resource type provider to use when managing elasticsearch instances.
#
# @param slm_policies
#   Define slm_policies via a hash. This is mainly used with Hiera's auto binding.
#
# @param snapshot_repositories
#   Define snapshot repositories via a hash. This is mainly used with Hiera's auto binding.
#
# @param ssl
#   Whether to manage TLS certificates. Requires the ca_certificate,
#   certificate, private_key and keystore_password parameters to be set.
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
#   Source for the x-pack system key. Valid values are any that are
#   supported for the file resource `source` parameter.
#
# @param systemd_service_path
#   Path to the directory in which to install systemd service units.
#
# @param templates
#   Define templates via a hash. This is mainly used with Hiera's auto binding.
#
# @param index_templates
#   Define index_templates via a hash. This is mainly used with Hiera's auto binding.
#
# @param component_templates
#   Define component_templates via a hash. This is mainly used with Hiera's auto binding.
#
# @param ilm_policies
#   Define ilm_policies via a hash. This is mainly used with Hiera's auto binding.
#
# @param users
#   Define templates via a hash. This is mainly used with Hiera's auto binding.
#
# @param validate_tls
#   Enable TLS/SSL validation on API calls.
#
# @param version
#   To set the specific version you want to install.
#
# @author Richard Pijnenburg <richard.pijnenburg@elasticsearch.com>
# @author Tyler Langlois <tyler.langlois@elastic.co>
# @author Gavin Williams <gavin.williams@elastic.co>
#
class elasticsearch (
  Enum['absent', 'present']                       $ensure,
  Optional[Variant[String, Sensitive[String]]]    $api_basic_auth_password,
  Optional[String]                                $api_basic_auth_username,
  Optional[String]                                $api_ca_file,
  Optional[String]                                $api_ca_path,
  String                                          $api_host,
  Integer[0, 65535]                               $api_port,
  Enum['http', 'https']                           $api_protocol,
  Integer                                         $api_timeout,
  Boolean                                         $autoupgrade,
  Hash                                            $config,
  Stdlib::Absolutepath                            $configdir,
  Integer                                         $configdir_recurselimit,
  Elasticsearch::Multipath                        $datadir,
  Optional[Stdlib::Absolutepath]                  $defaults_location,
  Optional[String]                                $download_tool,
  Optional[String]                                $download_tool_insecure,
  Boolean                                         $download_tool_verify_certificates,
  String                                          $elasticsearch_group,
  String                                          $elasticsearch_user,
  Stdlib::Absolutepath                            $homedir,
  Hash                                            $indices,
  Hash                                            $init_defaults,
  Optional[String]                                $init_defaults_file,
  String                                          $init_template,
  Array[String]                                   $jvm_options,
  Optional[Variant[String, Hash]]                 $license,
  Stdlib::Absolutepath                            $logdir,
  Boolean                                         $manage_datadir,
  Boolean                                         $manage_logdir,
  Boolean                                         $manage_repo,
  Boolean                                         $oss,
  Stdlib::Absolutepath                            $package_dir,
  Integer                                         $package_dl_timeout,
  String                                          $package_name,
  Enum['package']                                 $package_provider,
  Optional[String]                                $package_url,
  Optional[Stdlib::Absolutepath]                  $pid_dir,
  Hash                                            $pipelines,
  Optional[Stdlib::Absolutepath]                  $plugindir,
  Hash                                            $plugins,
  Optional[Stdlib::HTTPUrl]                       $proxy_url,
  Boolean                                         $purge_configdir,
  Boolean                                         $purge_package_dir,
  Boolean                                         $purge_secrets,
  Variant[Boolean, String]                        $repo_stage,
  Boolean                                         $restart_on_change,
  Hash                                            $roles,
  Hash                                            $scripts,
  Optional[Hash]                                  $secrets,
  String                                          $service_name,
  Enum['init', 'openbsd', 'openrc', 'systemd']    $service_provider,
  Hash                                            $snapshot_repositories,
  Boolean                                         $ssl,
  Elasticsearch::Status                           $status,
  Optional[String]                                $system_key,
  Stdlib::Absolutepath                            $systemd_service_path,
  Hash                                            $templates,
  Hash                                            $users,
  Boolean                                         $validate_tls,
  Variant[String, Boolean]                        $version,
  Hash                                            $index_templates           = {},
  Hash                                            $component_templates       = {},
  Hash                                            $ilm_policies              = {},
  Hash                                            $slm_policies              = {},
  Optional[Stdlib::Absolutepath]                  $ca_certificate            = undef,
  Optional[Stdlib::Absolutepath]                  $certificate               = undef,
  Optional[String]                                $keystore_password         = undef,
  Optional[Stdlib::Absolutepath]                  $keystore_path             = undef,
  Stdlib::Filemode                                $logdir_mode               = '2750',
  Optional[Variant[String, Array]]                $logging_content           = undef,
  Boolean                                         $package_hold              = false,
  Optional[Stdlib::Absolutepath]                  $private_key               = undef,
  Enum['rsa','dsa','ec']                          $private_key_type          = 'rsa',
  Boolean                                         $restart_config_change     = $restart_on_change,
  Boolean                                         $restart_package_change    = $restart_on_change,
  Boolean                                         $restart_plugin_change     = $restart_on_change,
) {
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

  # The OSS package distribution's package appends `-oss` to the end of the
  # canonical package name.
  $_package_name = $oss ? {
    true    => "${package_name}-oss",
    default => $package_name,
  }

  # Set the plugin path variable for use later in the module.
  if $plugindir == undef {
    $real_plugindir = "${homedir}/plugins"
  } else {
    $real_plugindir = $plugindir
  }

  # Should we restart Elasticsearch on config change?
  $_notify_service = $elasticsearch::restart_config_change ? {
    true  => Service[$elasticsearch::service_name],
    false => undef,
  }

  #### Manage actions

  contain elasticsearch::package
  contain elasticsearch::config
  contain elasticsearch::service

  create_resources('elasticsearch::index', $elasticsearch::indices)
  create_resources('elasticsearch::pipeline', $elasticsearch::pipelines)
  create_resources('elasticsearch::plugin', $elasticsearch::plugins)
  create_resources('elasticsearch::role', $elasticsearch::roles)
  create_resources('elasticsearch::script', $elasticsearch::scripts)
  create_resources('elasticsearch::snapshot_repository', $elasticsearch::snapshot_repositories)
  create_resources('elasticsearch::template', $elasticsearch::templates)
  $elasticsearch::component_templates.each |String $key, Hash $values| {
    elasticsearch::component_template { $key:
      * => $values,
    }
  }
  $elasticsearch::index_templates.each |String $key, Hash $values| {
    elasticsearch::index_template { $key:
      * => $values,
    }
  }
  $elasticsearch::ilm_policies.each |String $key, Hash $values| {
    elasticsearch::ilm_policy { $key:
      * => $values,
    }
  }
  $elasticsearch::slm_policies.each |String $key, Hash $values| {
    elasticsearch::slm_policy { $key:
      * => $values,
    }
  }
  create_resources('elasticsearch::user', $elasticsearch::users)

  if ($manage_repo == true) {
    if ($repo_stage == false) {
      # Use normal relationship ordering
      contain elastic_stack::repo

      Class['elastic_stack::repo']
      -> Class['elasticsearch::package']
    } else {
      # Use staging for ordering
      if !(defined(Stage[$repo_stage])) {
        stage { $repo_stage:  before => Stage['main'] }
      }

      include elastic_stack::repo
      Class<|title == 'elastic_stack::repo'|> {
        stage => $repo_stage,
      }
    }
  }

  if ($license != undef) {
    contain elasticsearch::license
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
    # Installation, configuration and service
    Class['elasticsearch::package']
    -> Class['elasticsearch::config']

    if $restart_config_change {
      Class['elasticsearch::config'] ~> Class['elasticsearch::service']
    } else {
      Class['elasticsearch::config'] -> Class['elasticsearch::service']
    }

    # Top-level ordering bindings for resources.
    Class['elasticsearch::config']
    -> Elasticsearch::Plugin <| ensure == 'present' or ensure == 'installed' |>
    Elasticsearch::Plugin <| ensure == 'absent' |>
    -> Class['elasticsearch::config']
    Class['elasticsearch::config']
    -> Elasticsearch::User <| ensure == 'present' |>
    # Elasticsearch::User <| ensure == 'absent' |>
    # -> Class['elasticsearch::config']
    # Class['elasticsearch::config']
    # -> Elasticsearch::Role <| |>
    Class['elasticsearch::config']
    -> Elasticsearch::Template <| |>
    Class['elasticsearch::config']
    -> Elasticsearch::Pipeline <| |>
    Class['elasticsearch::config']
    -> Elasticsearch::Index <| |>
    Class['elasticsearch::config']
    -> Elasticsearch::Snapshot_repository <| |>
  } else {
    # Absent; remove configuration before the package.
    Class['elasticsearch::config']
    -> Class['elasticsearch::package']

    # Top-level ordering bindings for resources.
    Elasticsearch::Plugin <| |>
    -> Class['elasticsearch::config']
    Elasticsearch::User <| |>
    -> Class['elasticsearch::config']
    Elasticsearch::Role <| |>
    -> Class['elasticsearch::config']
    Elasticsearch::Template <| |>
    -> Class['elasticsearch::config']
    Elasticsearch::Pipeline <| |>
    -> Class['elasticsearch::config']
    Elasticsearch::Index <| |>
    -> Class['elasticsearch::config']
    Elasticsearch::Snapshot_repository <| |>
    -> Class['elasticsearch::config']
  }

  # Install plugins before managing users/roles
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
  Elasticsearch::Role <| |>
  -> Elasticsearch::Snapshot_repository <| |>
  Elasticsearch::User <| |>
  -> Elasticsearch::Snapshot_repository <| |>

  # Ensure that any command-line based user changes are performed before the
  # file is modified
  Elasticsearch_user <| |>
  -> Elasticsearch_user_file <| |>

  # Ensure component templates are loaded before index templates
  Elasticsearch_component_template <| |>
  -> Elasticsearch_index_template <| |>

  # Ensure ILM policies are loaded before index or component templates
  Elasticsearch_ilm_policy <| |>
  -> Elasticsearch_component_template <| |>
  Elasticsearch_ilm_policy <| |>
  -> Elasticsearch_index_template <| |>

  # Ensure snapshot repositories are loaded before SLM policies
  Elasticsearch::Snapshot_repository <| |>
  -> Elasticsearch_slm_policy <| |>
}
