# == Define: elasticsearch::shield::user
#
# Manages shield users.
#
# === Parameters
#
# [*ensure*]
#   Whether the user should be present or not.
#   Set to 'absent' to ensure a user is not installed
#   Value type is string
#   Default value: present
#   This variable is optional
#
# [*password*]
#   Plaintext password for the given user.
#   Value type is string
#   Default value: undef
#
# [*provider*]
#   Shield realm to use to manage users. For Shield versions
#   < 2.3.0, only the file realm (esusers) is supported.
#   Value type is string
#   Default value: file
#
# [*roles*]
#   A list of roles to which the user should belong.
#   Value type is array
#   Default value: []
#
# === Examples
#
# # Creates and manages the user using esusers.
# elasticsearch::shield::user { 'bob': }
#
# === Authors
#
# * Tyler Langlois <mailto:tyler@elastic.co>
#
define elasticsearch::shield::user (
  $ensure    = 'present',
  $instances = []
  $password  = undef,
  $provider  = 'file',
  $roles     = [],
) {
  validate_string($ensure, $password, $provider)
  validate_array($roles)

  elasticsearch_shield_user { $name:
    ensure   => $ensure,
    password => $password,
    provider => $provider,
    roles    => $roles,
  }

  datacat_fragment { "shield_user_config_${instance}":
    target => "${instance_configdir}/elasticsearch.yml",
    data   => $instance_conf,
  }
}
