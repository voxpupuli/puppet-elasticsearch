#  This define allows you to insert, update or delete Elasticsearch index
#  templates.
#
#  Template content should be defined through either the `content` parameter
#  (when passing a hash or json string) or the `source` parameter (when passing
#  the puppet file URI to a template json file).
#
# @param ensure [String]
#   Controls whether the named index template should be present or absent in
#   the cluster.
#
# @param api_basic_auth_password [String]
#   HTTP basic auth password to use when communicating over the Elasticsearch
#   API.
#
# @param api_basic_auth_username [String]
#   HTTP basic auth username to use when communicating over the Elasticsearch
#   API.
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
#   Host name or IP address of the ES instance to connect to.
#
# @param api_port [Integer]
#   Port number of the ES instance to connect to
#
# @param api_protocol [String]
#   Protocol that should be used to connect to the Elasticsearch API.
#
# @param api_timeout [Integer]
#   Timeout period (in seconds) for the Elasticsearch API.
#
# @param content [Enum[String, Hash]]
#   Contents of the template. Can be either a puppet hash or a string
#   containing JSON.
#
# @param source [String]
#   Source path for the template file. Can be any value similar to `source`
#   values for `file` resources.
#
# @param validate_tls [Boolean]
#   Determines whether the validity of SSL/TLS certificates received from the
#   Elasticsearch API should be verified or ignored.
#
# @author Richard Pijnenburg <richard.pijnenburg@elasticsearch.com>
# @author Tyler Langlois <tyler.langlois@elastic.co>
#
define elasticsearch::template (
  $ensure                  = 'present',
  $api_basic_auth_password = $elasticsearch::api_basic_auth_password,
  $api_basic_auth_username = $elasticsearch::api_basic_auth_username,
  $api_ca_file             = $elasticsearch::api_ca_file,
  $api_ca_path             = $elasticsearch::api_ca_path,
  $api_host                = $elasticsearch::api_host,
  $api_port                = $elasticsearch::api_port,
  $api_protocol            = $elasticsearch::api_protocol,
  $api_timeout             = $elasticsearch::api_timeout,
  $content                 = undef,
  $source                  = undef,
  $validate_tls            = $elasticsearch::validate_tls,
) {
  validate_string(
    $api_protocol,
    $api_host,
    $api_basic_auth_username,
    $api_basic_auth_password
  )
  validate_bool($validate_tls)

  if ! ($ensure in ['present', 'absent']) {
    fail("'${ensure}' is not a valid 'ensure' parameter value")
  }
  if ! is_integer($api_port)    { fail('"api_port" is not an integer') }
  if ! is_integer($api_timeout) { fail('"api_timeout" is not an integer') }
  if ($api_ca_file != undef) { validate_absolute_path($api_ca_file) }
  if ($api_ca_path != undef) { validate_absolute_path($api_ca_path) }

  if $source != undef { validate_string($source) }

  if $content != undef and is_string($content) {
    $_content = parsejson($content)
  } else {
    $_content = $content
  }

  if $ensure == 'present' and $source == undef and $_content == undef {
    fail('one of "file" or "content" required.')
  } elsif $source != undef and $_content != undef {
    fail('"file" and "content" cannot be simultaneously defined.')
  }

  require elasticsearch

  es_instance_conn_validator { "${name}-template":
    server => $api_host,
    port   => $api_port,
  }
  -> elasticsearch_template { $name:
    ensure       => $ensure,
    content      => $_content,
    source       => $source,
    protocol     => $api_protocol,
    host         => $api_host,
    port         => $api_port,
    timeout      => $api_timeout,
    username     => $api_basic_auth_username,
    password     => $api_basic_auth_password,
    ca_file      => $api_ca_file,
    ca_path      => $api_ca_path,
    validate_tls => $validate_tls,
  }
}
