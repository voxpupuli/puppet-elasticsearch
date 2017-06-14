#  This define allows you to insert, update or delete Elasticsearch index
#  ingestion pipelines.
#
#  Pipeline content should be defined through the `content` parameter.
#
# @param ensure [String]
#   Controls whether the named pipeline should be present or absent in
#   the cluster.
#
# @param content [Hash]
#   Contents of the pipeline in hash form.
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
# @param validate_tls [Boolean]
#   Determines whether the validity of SSL/TLS certificates received from the
#   Elasticsearch API should be verified or ignored.
#
# @author Tyler Langlois <tyler.langlois@elastic.co>
#
define elasticsearch::pipeline (
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

  if $ensure == 'present' { validate_hash($content) }

  require elasticsearch

  es_instance_conn_validator { "${name}-ingest-pipeline":
    server => $api_host,
    port   => $api_port,
  }
  -> elasticsearch_pipeline { $name:
    ensure       => $ensure,
    content      => $content,
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
