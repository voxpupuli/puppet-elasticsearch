#  This define allows you to insert, update or delete Elasticsearch snapshot
#  lifecycle policy.
#
# @param ensure
#   Controls whether the named index template should be present or absent in
#   the cluster.
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
# @param schedule_time
#   Periodic or absolute schedule at which the policy creates snapshots and deletes expired snapshots
#
# @param repository
#   Repository used to store snapshots created by this policy.
#
# @param snapshot_name
#   Name of the snapshots
#
# @param config_include_global_state
#   If true, cluster states are included in snapshots. Defaults to false. 
#
# @param config_ignore_unavailable
#   If true, missing indices do not cause snapshot creation to fail and return an error. Defaults to false. 
#
# @param config_partial
#   Allow partial snapshots
#
# @param config_indices
#   Array of index names or wildcard pattern of index names included in snapshots. 
#
# @param retention_expire_after
#   Time period after which a snapshot is considered expired and eligible for deletion. 
#
# @param retention_min_count
#   Minimum number of snapshots to retain, even if the snapshots have expired. 
#
# @param retention_max_count
#   Maximum number of snapshots to retain, even if the snapshots have not yet expired. 
#   If the number of snapshots in the repository exceeds this limit, the policy retains the most recent snapshots and deletes older snapshots. 
#
# @author Thomas Manninger
define elasticsearch::snapshot_lifecycle_policy (
  Enum['absent', 'present']       $ensure                       = 'present',
  Optional[String]                $api_basic_auth_password      = $elasticsearch::api_basic_auth_password,
  Optional[String]                $api_basic_auth_username      = $elasticsearch::api_basic_auth_username,
  Optional[Stdlib::Absolutepath]  $api_ca_file                  = $elasticsearch::api_ca_file,
  Optional[Stdlib::Absolutepath]  $api_ca_path                  = $elasticsearch::api_ca_path,
  String                          $api_host                     = $elasticsearch::api_host,
  Integer[0, 65535]               $api_port                     = $elasticsearch::api_port,
  Enum['http', 'https']           $api_protocol                 = $elasticsearch::api_protocol,
  Integer                         $api_timeout                  = $elasticsearch::api_timeout,
  Boolean                         $validate_tls                 = $elasticsearch::validate_tls,
  String                          $schedule_time,
  String                          $repository,
  String                          $snapshot_name                = "<${name}-{now/d}>",
  Boolean                         $config_include_global_state  = false,
  Boolean                         $config_ignore_unavailable    = false,
  Boolean                         $config_partial               = false,
  Array[String]                   $config_indices               = [ '*', 'test' ],
  Optional[String]                $retention_expire_after       = undef,
  Optional[Integer]               $retention_min_count          = undef,
  Optional[Integer]               $retention_max_count          = undef,
) {

  es_instance_conn_validator { "${name}-snapshot_lifecycle_policy":
    server  => $api_host,
    port    => $api_port,
    timeout => $api_timeout,
  }
  -> elasticsearch_snapshot_lifecycle_policy { $name:
    ensure                        => $ensure,
    schedule_time                 => $schedule_time,
    repository                    => $repository,
    snapshot_name                 => $snapshot_name,
    config_include_global_state   => $config_include_global_state,
    config_ignore_unavailable     => $config_ignore_unavailable,
    config_partial                => $config_partial,
    config_indices                => $config_indices,
    retention_expire_after        => $retention_expire_after,
    retention_min_count           => $retention_min_count,
    retention_max_count           => $retention_max_count,
    protocol                      => $api_protocol,
    host                          => $api_host,
    port                          => $api_port,
    timeout                       => $api_timeout,
    username                      => $api_basic_auth_username,
    password                      => $api_basic_auth_password,
    ca_file                       => $api_ca_file,
    ca_path                       => $api_ca_path,
    validate_tls                  => $validate_tls,
  }
}
