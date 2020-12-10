#  This define allows you to insert, update or delete Elasticsearch ILM indicies
#  as a set. The name of this resource will be the name of the alias applied to
#  all ILM managed indicies under this resource.
#
# @param ensure
#  When `present`, an initial index will be created to bootstrap the ILM managed
#  index set. When `absent`, all indicies marked with the alias will be purged
#  from the server.
#
# @param api_basic_auth_password
#   HTTP basic auth password to use when communicating over the Elasticsearch
#   API.
#
# @param api_basic_auth_username
#   HTTP basic auth username to use when communicating over the Elasticsearch
#   API.
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
#   Host name or IP address of the ES instance to connect to.
#
# @param api_port
#   Port number of the ES instance to connect to
#
# @param api_protocol
#   Protocol that should be used to connect to the Elasticsearch API.
#
# @param api_timeout
#   Timeout period (in seconds) for the Elasticsearch API.
#
# @param name_pattern
#   The naming pattern to use for ILM managed indicies.
#
# @param validate_tls
#   Determines whether the validity of SSL/TLS certificates received from the
#   Elasticsearch API should be verified or ignored.
#
# @author Josh Perry <josh@6bit.com>
#
define elasticsearch::ilm_index (
  Enum['absent', 'present']       $ensure                  = 'present',
  Optional[String]                $api_basic_auth_password = $elasticsearch::api_basic_auth_password,
  Optional[String]                $api_basic_auth_username = $elasticsearch::api_basic_auth_username,
  Optional[Stdlib::Absolutepath]  $api_ca_file             = $elasticsearch::api_ca_file,
  Optional[Stdlib::Absolutepath]  $api_ca_path             = $elasticsearch::api_ca_path,
  String                          $api_host                = $elasticsearch::api_host,
  Integer[0, 65535]               $api_port                = $elasticsearch::api_port,
  Enum['http', 'https']           $api_protocol            = $elasticsearch::api_protocol,
  Integer                         $api_timeout             = $elasticsearch::api_timeout,
  String                          $name_pattern            = '{now/d}-000001',
  Boolean                         $validate_tls            = $elasticsearch::validate_tls,
) {
  es_instance_conn_validator { "${name}-ilm-index":
    server  => $api_host,
    port    => $api_port,
    timeout => $api_timeout,
  }
  -> elasticsearch_ilm_index { $name:
    ensure                     => $ensure,
    content                    => { aliases => { $name => { is_write_index => true } } },
    pattern                    => $name_pattern,
    protocol                   => $api_protocol,
    host                       => $api_host,
    port                       => $api_port,
    timeout                    => $api_timeout,
    username                   => $api_basic_auth_username,
    password                   => $api_basic_auth_password,
    ca_file                    => $api_ca_file,
    ca_path                    => $api_ca_path,
    validate_tls               => $validate_tls,
  }
}
