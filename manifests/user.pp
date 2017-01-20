# == Define: elasticsearch::user
#
# Manages shield/x-pack users.
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
#   Password for the given user. A plaintext password will be managed
#   with the esusers utility and requires a refresh to update, while
#   a hashed password from the esusers utility will be managed manually
#   in the uses file.
#   Value type is string
#   Default value: undef
#
# [*roles*]
#   A list of roles to which the user should belong.
#   Value type is array
#   Default value: []
#
# === Examples
#
# # Creates and manages a user with membership in the 'logstash'
# # and 'kibana4' roles.
# elasticsearch::user { 'bob':
#   password => 'foobar',
#   roles    => ['logstash', 'kibana4'],
# }
#
# === Authors
#
# * Tyler Langlois <mailto:tyler@elastic.co>
#
define elasticsearch::user (
  $password,
  $ensure = 'present',
  $roles  = [],
) {
  validate_string($ensure, $password)
  validate_array($roles)
  if $elasticsearch::security_plugin == undef or ! ($elasticsearch::security_plugin in ['shield', 'x-pack']) {
    fail("\"${elasticsearch::security_plugin}\" is not a valid security_plugin parameter value")
  }


  if $password =~ /^\$2a\$/ {
    elasticsearch_user { $name:
      ensure          => $ensure,
      hashed_password => $password,
    }
  } else {
    $_provider = $elasticsearch::security_plugin ? {
      'shield' => 'esusers',
      'x-pack' => 'users',
    }
    elasticsearch_user { $name:
      ensure   => $ensure,
      password => $password,
      provider => $_provider,
    }
  }

  elasticsearch_user_roles { $name:
    ensure => $ensure,
    roles  => $roles,
  }
}
