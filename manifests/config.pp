# This class exists to coordinate all configuration related actions,
# functionality and logical units in a central place.
#
# It is not intended to be used directly by external resources like node
# definitions or other modules.
#
# @example importing this class into other classes to use its functionality:
#   class { 'elasticsearch::config': }
#
# @author Richard Pijnenburg <richard.pijnenburg@elasticsearch.com>
# @author Tyler Langlois <tyler.langlois@elastic.co>
# @author Gavin Williams <gavin.williams@elastic.co>
#
class elasticsearch::config {

  #### Configuration

  Exec {
    path => [ '/bin', '/usr/bin', '/usr/local/bin' ],
    cwd  => '/',
  }

  $init_defaults = merge(
    {
      'MAX_OPEN_FILES' => '65535',
    },
    $elasticsearch::init_defaults
  )

  if ( $elasticsearch::ensure == 'present' ) {

    file {
      $elasticsearch::homedir:
        ensure => 'directory',
        group  => $elasticsearch::elasticsearch_group,
        owner  => $elasticsearch::elasticsearch_user;
      $elasticsearch::configdir:
        ensure => 'directory',
        group  => $elasticsearch::elasticsearch_group,
        owner  => 'root',
        mode   => '2750';
      $elasticsearch::datadir:
        ensure => 'directory',
        group  => $elasticsearch::elasticsearch_group,
        owner  => $elasticsearch::elasticsearch_user;
      $elasticsearch::logdir:
        ensure => 'directory',
        group  => $elasticsearch::elasticsearch_group,
        owner  => $elasticsearch::elasticsearch_user,
        mode   => '0750';
      $elasticsearch::_plugindir:
        ensure => 'directory',
        group  => $elasticsearch::elasticsearch_group,
        owner  => $elasticsearch::elasticsearch_user,
        mode   => 'o+Xr';
      "${elasticsearch::homedir}/lib":
        ensure  => 'directory',
        group   => '0',
        owner   => 'root',
        recurse => true;
    }

    if $elasticsearch::pid_dir {
      file { $elasticsearch::pid_dir:
        ensure  => 'directory',
        group   => undef,
        owner   => $elasticsearch::elasticsearch_user,
        recurse => true,
      }

      if ($elasticsearch::service_provider == 'systemd') {
        $group = $elasticsearch::elasticsearch_group
        $user = $elasticsearch::elasticsearch_user
        $pid_dir = $elasticsearch::pid_dir

        file { '/usr/lib/tmpfiles.d/elasticsearch.conf':
          ensure  => 'file',
          content => template("${module_name}/usr/lib/tmpfiles.d/elasticsearch.conf.erb"),
          group   => '0',
          owner   => 'root',
        }
      }
    }

    if $elasticsearch::defaults_location {
      augeas { "${elasticsearch::defaults_location}/elasticsearch":
        incl    => "${elasticsearch::defaults_location}/elasticsearch",
        lens    => 'Shellvars.lns',
        changes => [
          'rm CONF_FILE',
          'rm CONF_DIR',
          'rm ES_PATH_CONF',
        ],
      }

      file { "${elasticsearch::defaults_location}/elasticsearch":
        ensure => 'file',
        group  => $elasticsearch::elasticsearch_group,
        owner  => $elasticsearch::elasticsearch_user,
        mode   => '0640';
      }
    }

    # Defaults file, either from file source or from hash to augeas commands
    if ($elasticsearch::init_defaults_file != undef) {
      file { "${elasticsearch::defaults_location}/elasticsearch":
        ensure => $elasticsearch::ensure,
        source => $elasticsearch::init_defaults_file,
        owner  => 'root',
        group  => '0',
        mode   => '0644',
        before => Service['elasticsearch'],
        notify => $elasticsearch::_notify_service,
      }
    } else {
      augeas { 'init_defaults':
        incl    => "${elasticsearch::defaults_location}/elasticsearch",
        lens    => 'Shellvars.lns',
        changes => template("${module_name}/etc/sysconfig/defaults.erb"),
        before  => Service['elasticsearch'],
        notify  => $elasticsearch::_notify_service,
      }
    }

    # Generate config file
    $_config = deep_implode($elasticsearch::config)

    # Generate SSL config
    if $elasticsearch::ssl {
      if ($elasticsearch::keystore_password == undef) {
        fail('keystore_password required')
      }

      if ($elasticsearch::keystore_path == undef) {
        $_keystore_path = "${elasticsearch::configdir}/elasticsearch.ks"
      } else {
        $_keystore_path = $elasticsearch::keystore_path
      }

      $_tls_config = {
        'xpack.security.transport.ssl.enabled' => true,
        'xpack.security.http.ssl.enabled'      => true,
        'xpack.ssl.keystore.path'              => $_keystore_path,
        'xpack.ssl.keystore.password'          => $elasticsearch::keystore_password,
      }

      # Trust CA Certificate
      java_ks { 'elasticsearch_ca':
        ensure       => 'latest',
        certificate  => $elasticsearch::ca_certificate,
        target       => $_keystore_path,
        password     => $elasticsearch::keystore_password,
        trustcacerts => true,
      }

      # Load node certificate and private key
      java_ks { 'elasticsearch_node':
        ensure      => 'latest',
        certificate => $elasticsearch::certificate,
        private_key => $elasticsearch::private_key,
        target      => $_keystore_path,
        password    => $elasticsearch::keystore_password,
      }
    } else {
      $_tls_config = {}
    }

    # Logging file or hash
    if ($elasticsearch::logging_file != undef) {
      $_log4j_content = undef
    } else {
      if ($elasticsearch::logging_template != undef ) {
        $_log4j_content = template($elasticsearch::logging_template)
      } else {
        $_log4j_content = template("${module_name}/etc/elasticsearch/log4j2.properties.erb")
      }
      $_logging_source = undef
    }
    file {
      "${elasticsearch::configdir}/log4j2.properties":
        ensure  => file,
        content => $_log4j_content,
        source  => $_logging_source,
        mode    => '0644',
        notify  => $elasticsearch::_notify_service,
        require => Class['elasticsearch::package'],
        before  => Class['elasticsearch::service'],
    }

    # Generate Elasticsearch config
    $_es_config = merge(
      $elasticsearch::config,
      { 'path.data' => $elasticsearch::datadir },
      { 'path.logs' => $elasticsearch::logdir },
      $_tls_config
    )

    datacat_fragment { 'main_config':
      target => "${elasticsearch::configdir}/elasticsearch.yml",
      data   => $_es_config,
    }

    datacat { "${elasticsearch::configdir}/elasticsearch.yml":
      template => "${module_name}/etc/elasticsearch/elasticsearch.yml.erb",
      notify   => $elasticsearch::_notify_service,
      require  => Class['elasticsearch::package'],
      owner    => $elasticsearch::elasticsearch_user,
      group    => $elasticsearch::elasticsearch_group,
      mode     => '0440',
    }

    # Add any additional JVM options
    $elasticsearch::jvm_options.each |String $jvm_option| {
      file_line { "jvm_option_${jvm_option}":
        ensure => present,
        path   => "${elasticsearch::configdir}/jvm.options",
        line   => $jvm_option,
        notify => $elasticsearch::_notify_service,
      }
    }

    if $elasticsearch::system_key != undef {
      file { "${elasticsearch::configdir}/system_key":
        ensure => 'file',
        source => $elasticsearch::system_key,
        mode   => '0400',
      }
    }

    # Add secrets to keystore
    if $elasticsearch::secrets != undef {
      elasticsearch_keystore { 'elasticsearch_secrets':
        configdir => $elasticsearch::configdir,
        purge     => $elasticsearch::purge_secrets,
        settings  => $elasticsearch::secrets,
        notify    => $::elaticsearch::_notify_service,
      }
    }

  } elsif ( $elasticsearch::ensure == 'absent' ) {
    file { $elasticsearch::_plugindir:
      ensure => 'absent',
      force  => true,
      backup => false,
    }

    file { "${elasticsearch::configdir}/jvm.options":
      ensure => 'absent',
    }

    file { "${elasticsearch::defaults_location}/elasticsearch":
      ensure    => 'absent',
      subscribe => Service['elasticsearch'],
    }
  }
}
