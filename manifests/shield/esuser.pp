#
# == Class: elasticsearch::shield::esuser
#
#  Class to manage creating users in elasticsearch via the shield plugin
#
# == Parameters
#
#  [*username*]
#    String to use for a username
#
#  [*password*]
#    String to use for a password
#
define elasticsearch::shield::esuser($username, $password, $roles=$title) {
  if $username == undef {
    fail('user must be specified')
  }
  validate_string($username)
  if $password == undef {
    fail('password must be specified')
  }
  validate_slength($password, 4192, 6)
  
  # TODO: what happens if we add roles - this route we only set role on useradd
  exec { "useradd shield::esuser::${username}":
    path    => [ '/usr/bin', '/usr/share/elasticsearch/bin/shield' ],
    command => "esusers useradd ${username} -p \"${password}\" -r ${roles} &> /dev/null",
    unless  => "esusers list ${username} &> /dev/null",
  }
}
