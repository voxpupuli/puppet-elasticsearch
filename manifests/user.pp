# Manages x-pack users.
#
# @example creates and manage a user with membership in the 'logstash' and 'kibana4' roles.
#   elasticsearch::user { 'bob':
#     password => 'foobar',
#     roles    => ['logstash', 'kibana4'],
#   }
#
# @param ensure
#   Whether the user should be present or not.
#   Set to `absent` to ensure a user is not installed
#
# @param password
#   Password for the given user. A plaintext password will be managed
#   with the esusers utility and requires a refresh to update, while
#   a hashed password from the esusers utility will be managed manually
#   in the uses file.
#
# @param roles
#   A list of roles to which the user should belong.
#
# @author Tyler Langlois <tyler.langlois@elastic.co>
# @author Gavin Williams <gavin.williams@elastic.co>
#
define elasticsearch::user (
  Optional[String]          $password = undef,
  Enum['absent', 'present'] $ensure   = 'present',
  Array                     $roles    = [],
) {
  if $ensure == 'absent' {
    elasticsearch_user { $name:
      ensure    => 'absent',
      configdir => $elasticsearch::configdir,
    }
  }
  else {
    if $password == undef {
      fail('elasticsearch::user: password must be provided when ensure => present')
    }
    if $password =~ /^\$2a\$/ {
      elasticsearch_user_file { $name:
        ensure          => present,
        configdir       => $elasticsearch::configdir,
        hashed_password => $password,
        before          => Elasticsearch_user_roles[$name],
      }
    } else {
      elasticsearch_user { $name:
        ensure    => present,
        configdir => $elasticsearch::configdir,
        password  => $password,
        before    => Elasticsearch_user_roles[$name],
      }
    }
  }
  elasticsearch_user_roles { $name:
    ensure => $ensure,
    roles  => $roles,
  }
}
