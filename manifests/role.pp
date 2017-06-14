# Manage shield/x-pack roles.
#
# @param ensure [String]
#   Whether the role should be present or not.
#   Set to 'absent' to ensure a role is not present.
#
# @param mappings [Array]
#   A list of optional mappings defined for this role.
#
# @param privileges [Hash]
#   A hash of permissions defined for the role. Valid privilege settings can
#   be found in the Shield/x-pack documentation.
#
# @example create and manage the role 'power_user' mapped to an LDAP group.
#   elasticsearch::role { 'power_user':
#     privileges => {
#       'cluster' => 'monitor',
#       'indices' => {
#         '*' => 'all',
#       },
#     },
#     mappings => [
#       "cn=users,dc=example,dc=com",
#     ],
#   }
#
# @author Tyler Langlois <tyler.langlois@elastic.co>
#
define elasticsearch::role (
  $ensure     = 'present',
  $mappings   = [],
  $privileges = {},
) {
  validate_string($ensure)
  validate_array($mappings)
  validate_hash($privileges)
  validate_slength($name, 30, 1)
  if $elasticsearch::security_plugin == undef or ! ($elasticsearch::security_plugin in ['shield', 'x-pack']) {
    fail("\"${elasticsearch::security_plugin}\" is not a valid security_plugin parameter value")
  }

  if empty($privileges) or $ensure == 'absent' {
    $_role_ensure = 'absent'
  } else {
    $_role_ensure = $ensure
  }

  if empty($mappings) or $ensure == 'absent' {
    $_mapping_ensure = 'absent'
  } else {
    $_mapping_ensure = $ensure
  }

  elasticsearch_role { $name :
    ensure     => $_role_ensure,
    privileges => $privileges,
  }

  elasticsearch_role_mapping { $name :
    ensure   => $_mapping_ensure,
    mappings => $mappings,
  }
}
