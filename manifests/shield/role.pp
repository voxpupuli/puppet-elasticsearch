# == Define: elasticsearch::shield::role
#
# Manage shield roles.
#
# === Parameters
#
# [*privileges*]
#   A hash of permissions defined for the role.
#   Value type is hash
#   Default value: {}
#
# === Examples
#
# # Creates and manages the role 'power_user'
# elasticsearch::shield::role { 'power_user':
#   privileges => {
#     'cluster' => 'monitor',
#     'indices' => {
#       '*' => 'all',
#     },
#   },
# }
#
# === Authors
#
# * Tyler Langlois <mailto:tyler@elastic.co>
#
define elasticsearch::shield::role (
  $ensure     = 'present',
  $privileges = {},
) {
  validate_string($ensure)
  validate_hash($privileges)

  elasticsearch_shield_role { $name :
    ensure     => $ensure,
    privileges => $privileges,
  }
}
