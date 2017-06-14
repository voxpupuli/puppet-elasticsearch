#  This define allows you to create or remove an elasticsearch instance
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
# @param ca_certificate [String]
#   Path to the trusted CA certificate to add to this node's java keystore.
#
# @param certificate [String]
#   Path to the certificate for this node signed by the CA listed in
#   ca_certificate.
#
# @param config [Hash]
#   Elasticsearch configuration hash.
#
# @param configdir [String]
#   Path to directory containing the elasticsearch configuration.
#   Use this setting if your packages deviate from the norm (/etc/elasticsearch).
#
# @param daily_rolling_date_pattern [String]
#   File pattern for the file appender log when file_rolling_type is `dailyRollingFile`
#
# @param datadir [String]
#   Allows you to set the data directory of Elasticsearch
#
# @param datadir_instance_directories [Boolean]
#   Control whether individual directories for instances will be created within
#   each instance's data directory.
#
# @param deprecation_logging [Boolean]
#   Wheter to enable deprecation logging. If enabled, deprecation logs will be
#   saved to ${cluster.name}_deprecation.log in the elastic search log folder.
#
# @param deprecation_logging_level [String]
#   Default deprecation logging level for Elasticsearch.
#
# @param file_rolling_type [String]
#   Configuration for the file appender rotation. It can be `dailyRollingFile`
#   or `rollingFile`. The first rotates by name, and the second one by size.
#
# @param init_defaults [Hash]
#   Defaults file content in hash representation.
#
# @param init_defaults_file [String]
#   Defaults file as puppet resource.
#
# @param init_template [String]
#   Service file as a template
#
# @param keystore_password [String]
#   Password to encrypt this node's Java keystore.
#
# @param keystore_path [String]
#   Custom path to the java keystore file. This parameter is optional.
#
# @param logdir [String]
#   Log directory for this instance.
#
# @param logging_config [Hash]
#   Hash representation of information you want in the logging.yml file.
#
# @param logging_file [String]
#   Instead of a hash you can supply a puppet:// file source for the logging.yml file
#
# @param logging_level [String]
#   Default logging level for Elasticsearch.
#
# @param logging_template [String]
#  Use a custom logging template - just supply the reative path, ie
#  $module_name/elasticsearch/logging.yml.erb
#
# @param private_key [String]
#   Path to the key associated with this node's certificate.
#
# @param purge_secrets [Boolean]
#   Whether or not keys present in the keystore will be removed if they are not
#   present in the specified secrets hash.
#
# @param rolling_file_max_backup_index [Integer]
#   Max number of logs to store whern file_rolling_type is `rollingFile`
#
# @param rolling_file_max_file_size [String]
#   Max log file size when file_rolling_type is `rollingFile`
#
# @param secrets [Hash]
#   Optional configuration hash of key/value pairs to store in the instance's
#   Elasticsearch keystore file. If unset, the keystore is left unmanaged.
#
# @param security_plugin [String]
#   Which security plugin will be used to manage users, roles, and
#   certificates. Inherited from top-level Elasticsearch class.
#
# @param service_flags [String]
#   Service flags used for the OpenBSD service configuration, defaults to undef.
#
# @param ssl [Boolean]
#   Whether to manage TLS certificates for Shield. Requires the ca_certificate,
#   certificate, private_key and keystore_password parameters to be set.
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
#   Source for the Shield system key. Valid values are any that are
#   supported for the file resource `source` parameter.
#
# @author Richard Pijnenburg <richard.pijnenburg@elasticsearch.com>
# @author Tyler Langlois <tyler.langlois@elastic.co>
#
define elasticsearch::instance (
  $ensure                        = $elasticsearch::ensure,
  $ca_certificate                = undef,
  $certificate                   = undef,
  $config                        = undef,
  $configdir                     = undef,
  $daily_rolling_date_pattern    = $elasticsearch::daily_rolling_date_pattern,
  $datadir                       = undef,
  $datadir_instance_directories  = $elasticsearch::datadir_instance_directories,
  $deprecation_logging           = false,
  $deprecation_logging_level     = 'DEBUG',
  $file_rolling_type             = $elasticsearch::file_rolling_type,
  $init_defaults                 = undef,
  $init_defaults_file            = undef,
  $init_template                 = $elasticsearch::init_template,
  $keystore_password             = undef,
  $keystore_path                 = undef,
  $logdir                        = undef,
  $logging_config                = undef,
  $logging_file                  = undef,
  $logging_level                 = $elasticsearch::default_logging_level,
  $logging_template              = undef,
  $private_key                   = undef,
  $purge_secrets                 = $elasticsearch::purge_secrets,
  $rolling_file_max_backup_index = $elasticsearch::rolling_file_max_backup_index,
  $rolling_file_max_file_size    = $elasticsearch::rolling_file_max_file_size,
  $secrets                       = undef,
  $security_plugin               = $elasticsearch::security_plugin,
  $service_flags                 = undef,
  $ssl                           = false,
  $status                        = $elasticsearch::status,
  $system_key                    = $elasticsearch::system_key,
) {

  require elasticsearch::params

  File {
    owner => $elasticsearch::elasticsearch_user,
    group => $elasticsearch::elasticsearch_group,
  }

  Exec {
    path => [ '/bin', '/usr/bin', '/usr/local/bin' ],
    cwd  => '/',
  }

  # ensure
  if ! ($ensure in [ 'present', 'absent' ]) {
    fail("\"${ensure}\" is not a valid ensure parameter value")
  }

  if $ssl or ($system_key != undef) {
    if $security_plugin == undef or ! ($security_plugin in ['shield', 'x-pack']) {
      fail("\"${security_plugin}\" is not a valid security_plugin parameter value")
    }
  }

  $notify_service = $elasticsearch::restart_config_change ? {
    true  => Elasticsearch::Service[$name],
    false => undef,
  }

  # Instance config directory
  if ($configdir == undef) {
    $instance_configdir = "${elasticsearch::configdir}/${name}"
  } else {
    $instance_configdir = $configdir
  }

  if ($ensure == 'present') {

    # Configuration hash
    if ($config == undef) {
      $instance_config = {}
    } else {
      validate_hash($config)
      $instance_config = deep_implode($config)
    }

    if(has_key($instance_config, 'node.name')) {
      $instance_node_name = {}
    } else {
      $instance_node_name = { 'node.name' => "${::hostname}-${name}" }
    }

    # String or array for data dir(s)
    if ($datadir == undef) {
      validate_bool($datadir_instance_directories)
      if ($datadir_instance_directories) {
        if (is_array($elasticsearch::datadir)) {
          $instance_datadir = array_suffix($elasticsearch::datadir, "/${name}")
        } else {
          $instance_datadir = "${elasticsearch::datadir}/${name}"
        }
      } else {
        $instance_datadir = $elasticsearch::datadir
      }
    } else {
      $instance_datadir = $datadir
    }

    # Logging file or hash
    if ($logging_file != undef) {
      $logging_source = $logging_file
      $logging_content = undef
      $_log4j_content = undef
    } elsif ($elasticsearch::logging_file != undef) {
      $logging_source = $elasticsearch::logging_file
      $logging_content = undef
      $_log4j_content = undef
    } else {

      if(is_hash($elasticsearch::logging_config)) {
        $main_logging_config = deep_implode($elasticsearch::logging_config)
      } else {
        $main_logging_config = { }
      }

      if(is_hash($logging_config)) {
        $instance_logging_config = deep_implode($logging_config)
      } else {
        $instance_logging_config = { }
      }
      $logging_hash = merge(
        $elasticsearch::params::logging_defaults,
        $main_logging_config,
        $instance_logging_config
      )
      if ($logging_template != undef ) {
        $logging_content = template($logging_template)
        $_log4j_content = template($logging_template)
      } elsif ($elasticsearch::logging_template != undef) {
        $logging_content = template($elasticsearch::logging_template)
        $_log4j_content = template($elasticsearch::logging_template)
      } else {
        $logging_content = template("${module_name}/etc/elasticsearch/logging.yml.erb")
        $_log4j_content = template("${module_name}/etc/elasticsearch/log4j2.properties.erb")
      }
      $logging_source = undef
    }

    if ($elasticsearch::x_config != undef) {
      $main_config = deep_implode($elasticsearch::x_config)
    } else {
      $main_config = { }
    }

    $instance_datadir_config = { 'path.data' => $instance_datadir }

    if(is_array($instance_datadir)) {
      $dirs = join($instance_datadir, ' ')
    } else {
      $dirs = $instance_datadir
    }

    # Manage instance log directory
    if ($logdir == undef) {
      $instance_logdir = "${elasticsearch::logdir}/${name}"
    } else {
      $instance_logdir = $logdir
    }

    $instance_logdir_config = { 'path.logs' => $instance_logdir }

    validate_bool($ssl)
    if $ssl {
      validate_absolute_path($ca_certificate, $certificate, $private_key)
      validate_string($keystore_password)

      if ($keystore_path == undef) {
        $_keystore_path = "${instance_configdir}/${security_plugin}/${name}.ks"
      } else {
        validate_absolute_path($keystore_path)
        $_keystore_path = $keystore_path
      }

      if $security_plugin == 'shield' {
        $tls_config = {
          'shield.transport.ssl'         => true,
          'shield.http.ssl'              => true,
          'shield.ssl.keystore.path'     => $_keystore_path,
          'shield.ssl.keystore.password' => $keystore_password,
        }
      } elsif $security_plugin == 'x-pack' {
        $tls_config = {
          'xpack.security.transport.ssl.enabled' => true,
          'xpack.security.http.ssl.enabled'      => true,
          'xpack.ssl.keystore.path'              => $_keystore_path,
          'xpack.ssl.keystore.password'          => $keystore_password,
        }
      }

      # Trust CA Certificate
      java_ks { "elasticsearch_instance_${name}_keystore_ca":
        ensure       => 'latest',
        certificate  => $ca_certificate,
        target       => $_keystore_path,
        password     => $keystore_password,
        trustcacerts => true,
      }

      # Load node certificate and private key
      java_ks { "elasticsearch_instance_${name}_keystore_node":
        ensure      => 'latest',
        certificate => $certificate,
        private_key => $private_key,
        target      => $_keystore_path,
        password    => $keystore_password,
      }
    } else { $tls_config = {} }

    if $system_key != undef {
      validate_string($system_key)
    }

    exec { "mkdir_logdir_elasticsearch_${name}":
      command => "mkdir -p ${instance_logdir}",
      creates => $instance_logdir,
      require => Class['elasticsearch::package'],
      before  => File[$instance_logdir],
    }

    file { $instance_logdir:
      ensure  => 'directory',
      owner   => $elasticsearch::elasticsearch_user,
      group   => undef,
      mode    => '0644',
      require => Class['elasticsearch::package'],
      before  => Elasticsearch::Service[$name],
    }

    if ($datadir_instance_directories) {
      exec { "mkdir_datadir_elasticsearch_${name}":
        command => "mkdir -p ${dirs}",
        creates => $instance_datadir,
        require => Class['elasticsearch::package'],
        before  => Elasticsearch::Service[$name],
      }
      -> file { $instance_datadir:
        ensure  => 'directory',
        owner   => $elasticsearch::elasticsearch_user,
        group   => undef,
        mode    => '0644',
        require => Class['elasticsearch::package'],
        before  => Elasticsearch::Service[$name],
      }
    }

    exec { "mkdir_configdir_elasticsearch_${name}":
      command => "mkdir -p ${instance_configdir}",
      creates => $elasticsearch::configdir,
      require => Class['elasticsearch::package'],
      before  => Elasticsearch::Service[$name],
    }

    file { $instance_configdir:
      ensure  => 'directory',
      mode    => '0644',
      purge   => $elasticsearch::purge_configdir,
      force   => $elasticsearch::purge_configdir,
      require => [ Exec["mkdir_configdir_elasticsearch_${name}"], Class['elasticsearch::package'] ],
      before  => Elasticsearch::Service[$name],
    }

    file {
      "${instance_configdir}/logging.yml":
        ensure  => file,
        content => $logging_content,
        source  => $logging_source,
        mode    => '0644',
        notify  => $notify_service,
        require => Class['elasticsearch::package'],
        before  => Elasticsearch::Service[$name];
      "${instance_configdir}/log4j2.properties":
        ensure  => file,
        content => $_log4j_content,
        source  => $logging_source,
        mode    => '0644',
        notify  => $notify_service,
        require => Class['elasticsearch::package'],
        before  => Elasticsearch::Service[$name];
    }

    file { "${instance_configdir}/scripts":
      ensure => 'link',
      target => "${elasticsearch::params::homedir}/scripts",
    }

    if $security_plugin != undef {
      file { "${instance_configdir}/${security_plugin}":
        ensure  => 'directory',
        mode    => '0644',
        source  => "${elasticsearch::configdir}/${security_plugin}",
        recurse => 'remote',
        owner   => 'root',
        group   => '0',
        before  => Elasticsearch::Service[$name],
        notify  => $notify_service,
      }
    }

    if $system_key != undef {
      file { "${instance_configdir}/${security_plugin}/system_key":
        ensure  => 'file',
        source  => $system_key,
        mode    => '0400',
        before  => Elasticsearch::Service[$name],
        require => File["${instance_configdir}/${security_plugin}"],
      }
    }

    # build up new config
    $instance_conf = merge(
      $main_config,
      $instance_node_name,
      $instance_datadir_config,
      $instance_logdir_config,
      $tls_config,
      $instance_config
    )

    # defaults file content
    # ensure user did not provide both init_defaults and init_defaults_file
    if (($init_defaults != undef) and ($init_defaults_file != undef)) {
      fail ('Only one of $init_defaults and $init_defaults_file should be defined')
    }

    if (is_hash($elasticsearch::init_defaults)) {
      $global_init_defaults = $elasticsearch::init_defaults
    } else {
      $global_init_defaults = { }
    }

    $instance_init_defaults_main = {
      'CONF_DIR'  => $instance_configdir,
      'ES_HOME'   => $elasticsearch::params::homedir,
      'LOG_DIR'   => $instance_logdir,
    }

    if (is_hash($init_defaults)) {
      $instance_init_defaults = $init_defaults
    } else {
      $instance_init_defaults = { }
    }
    $init_defaults_new = merge(
      { 'DATA_DIR'  => $elasticsearch::params::datadir },
      $global_init_defaults,
      $instance_init_defaults_main,
      $instance_init_defaults
    )

    $user = $elasticsearch::elasticsearch_user
    $group = $elasticsearch::elasticsearch_group

    datacat_fragment { "main_config_${name}":
      target => "${instance_configdir}/elasticsearch.yml",
      data   => $instance_conf,
    }

    datacat { "${instance_configdir}/elasticsearch.yml":
      template => "${module_name}/etc/elasticsearch/elasticsearch.yml.erb",
      notify   => $notify_service,
      require  => Class['elasticsearch::package'],
      owner    => $elasticsearch::elasticsearch_user,
      group    => $elasticsearch::elasticsearch_group,
      mode     => '0440',
    }

    if ($elasticsearch::secrets != undef or $secrets != undef) {
      if ($elasticsearch::secrets != undef) {
        $main_secrets = $elasticsearch::secrets
      } else {
        $main_secrets = {}
      }

      if ($secrets != undef) {
        $instance_secrets = $secrets
      } else {
        $instance_secrets = {}
      }

      validate_bool($purge_secrets)

      elasticsearch_keystore { $name :
        purge    => $purge_secrets,
        settings => merge($main_secrets, $instance_secrets),
        notify   => $notify_service,
      }
    }

    $require_service = Class['elasticsearch::package']
    $before_service  = undef

  } else {

    file { $instance_configdir:
      ensure  => 'absent',
      recurse => true,
      force   => true,
    }

    $require_service = undef
    $before_service  = File[$instance_configdir]

    $init_defaults_new = {}
  }

  elasticsearch::service { $name:
    ensure             => $ensure,
    status             => $status,
    service_flags      => $service_flags,
    init_defaults      => $init_defaults_new,
    init_defaults_file => $init_defaults_file,
    init_template      => $init_template,
    require            => $require_service,
    before             => $before_service,
  }

}
