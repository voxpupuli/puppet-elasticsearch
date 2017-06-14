# Manages shield/x-pack users.
#
# @example creates and manage a user with membership in the 'logstash' and 'kibana4' roles.
#   elasticsearch::user { 'bob':
#     password => 'foobar',
#     roles    => ['logstash', 'kibana4'],
#   }
#
# @param ensure [String]
#   Whether the user should be present or not.
#   Set to `absent` to ensure a user is not installed
#
# @param password [String]
#   Password for the given user. A plaintext password will be managed
#   with the esusers utility and requires a refresh to update, while
#   a hashed password from the esusers utility will be managed manually
#   in the uses file.
#
# @param roles [Array]
#   A list of roles to which the user should belong.
#
# @author Tyler Langlois <tyler.langlois@elastic.co>
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
