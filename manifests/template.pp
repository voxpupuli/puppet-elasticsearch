# == Define: elasticsearch::template
#
#  This define allows you to insert, update or delete Elasticsearch index
#  templates.
#
# === Parameters
#
# [*ensure*]
#   Controls whether the named index template should be present or absent in
#   the cluster.
#   Value type is string
#   Default value: present
#
# [*file*]
#   File path of the template (json file)
#   Value type is string
#   Default value: undef
#   This variable is optional
#
# [*content*]
#   Contents of the template. Can be either a puppet hash or a string
#   containing JSON.
#   Value type is string or hash.
#   Default value: undef
#   This variable is optional
#
# [*api_protocol*]
#   Protocol that should be used to connect to the Elasticsearch API.
#   Value type is string
#   Default value inherited from elasticsearch::api_protocol: http
#
# [*api_host*]
#   Host name or IP address of the ES instance to connect to
#   Value type is string
#   Default value inherited from $elasticsearch::api_host: localhost
#   This variable is optional
#
# [*api_port*]
#   Port number of the ES instance to connect to
#   Value type is number
#   Default value inherited from $elasticsearch::api_port: 9200
#   This variable is optional
#
# [*api_timeout*]
#   Timeout period (in seconds) for the Elasticsearch API.
#   Value type is int
#   Default value inherited from elasticsearch::api_timeout: 10
#
# [*validate_tls*]
#   Determines whether the validity of SSL/TLS certificates received from the
#   Elasticsearch API should be verified or ignored.
#   Value type is boolean
#   Default value inherited from elasticsearch::validate_tls: true
#
# [*basic_auth_username*]
#   HTTP basic auth username to use when communicating over the Elasticsearch
#   API.
#   Value type is String
#   Default value inherited from elasticsearch::basic_auth_username: undef
#
# [*basic_auth_password*]
#   HTTP basic auth password to use when communicating over the Elasticsearch
#   API.
#   Value type is String
#   Default value inherited from elasticsearch::basic_auth_password undef
#
# === Authors
#
# * Richard Pijnenburg <mailto:richard.pijnenburg@elasticsearch.com>
# * Tyler Langlois <mailto:tyler@elastic.co>
#
define elasticsearch::template (
  $ensure              = 'present',
  $file                = undef,
  $content             = undef,
  $api_protocol        = $elasticsearch::api_protocol,
  $api_host            = $elasticsearch::api_host,
  $api_port            = $elasticsearch::api_port,
  $api_timeout         = $elasticsearch::api_timeout,
  $validate_tls        = $elasticsearch::validate_tls,
  $basic_auth_username = $elasticsearch::basic_auth_username,
  $basic_auth_password = $elasticsearch::basic_auth_password,
) {
  validate_string(
    $api_protocol,
    $api_host,
    $basic_auth_username,
    $basic_auth_password
  )
  validate_bool($validate_tls)

  if ! ($ensure in ['present', 'absent']) {
    fail("'${ensure}' is not a valid ensure parameter value")
  }
  if ! is_integer($api_port)    { fail("'${api_port}' is not an integer") }
  if ! is_integer($api_timeout) { fail("'${api_timeout}' is not an integer") }

  if ($ensure == 'present') {
    if $file == undef and $content == undef {
      fail('one of "file" or "content" required.')
    } elsif $file != undef and $content != undef {
      fail('"file" and "content" cannot be simultaneously defined.')
    }
  }

  require elasticsearch

  elasticsearch_template { $name:
    content    => $content,
    protocol   => $api_protocol,
    host       => $api_host,
    port       => $api_port,
    timeout    => $api_timeout,
    ssl_verify => $validate_tls,
    username   => $basic_auth_username,
    password   => $basic_auth_password,
  }
}
