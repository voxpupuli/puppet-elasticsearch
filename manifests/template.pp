# == Define: elasticsearch::template
#
#  This define allows you to insert, update or delete templates that are used within Elasticsearch for the indexes
#
# === Parameters
#
# [*file*]
#   File path of the template ( json file )
#   Value type is string
#   Default value: undef
#   This variable is optional
#
# [*replace*]
#   Set to 'true' if you intend to replace the existing template
#   Value type is boolean
#   Default value: false
#   This variable is optional
#
# [*delete*]
#   Set to 'true' if you intend to delete the existing template
#   Value type is boolean
#   Default value: false
#   This variable is optional
#
# [*host*]
#   Host name or IP address of the ES instance to connect to
#   Value type is string
#   Default value: localhost
#   This variable is optional
#
# [*port*]
#   Port number of the ES instance to connect to
#   Value type is number
#   Default value: 9200
#   This variable is optional
#
# === Authors
#
# * Richard Pijnenburg <mailto:richard@ispavailability.com>
#
define elasticsearch::template(
  $file    = undef,
  $replace = false,
  $delete  = false,
  $host    = 'localhost',
  $port    = 9200
) {

  require elasticsearch

  Exec {
    path => [ '/bin', '/usr/bin', '/usr/local/bin' ]
  }

  # Build up the url
  $es_url = "http://${host}:${port}/_template/${name}"

  # Can't do a replace and delete at the same time
  if $replace == true and $delete == true {
    fail('Replace and Delete cant be used together')
  }

  if $delete == false {
    # Fail when no file is supplied
    if $file == undef {
      fail('The variable "file" cannot be empty when inserting or updating a template')
    }
  }

  $file_ensure = $delete ? {
    true  => 'absent',
    false => 'present'
  }

  $file_notify = $delete ? {
    true  => undef,
    false => Exec[ "insert_template ${name}" ]
  }

  # place the template file
  file { "${elasticsearch::confdir}/templates_import/elasticsearch-template-${name}.json":
    ensure  => $file_ensure,
    source  => $file,
    notify  => $file_notify,
    require => Exec[ 'mkdir_templates' ],
  }

  if $replace == true or $delete == true {

    # Only notify the insert_template call when we do a replace.
    $exec_notify = $replace ? {
      true  => Exec[ "insert_template ${name}" ],
      false => undef
    }

    # Delete the existing template
    # First check if it exists of course
    exec { "delete_template ${name}":
      command => "curl -s -XDELETE ${es_url}",
      onlyif  => "test $(curl -s '${es_url}?pretty=true' | wc -l) -gt 1",
      notify  => $exec_notify
    }

  }

  # Insert the template if we don't delete an existing one
  # Before inserting we check if a template exists with that same name
  if $delete == false {
    exec { "insert_template ${name}":
      command     => "curl -s -XPUT ${es_url} -d @${elasticsearch::confdir}/templates_import/elasticsearch-template-${name}.json",
      unless      => "test $(curl -s '${es_url}?pretty=true' | wc -l) -gt 1",
      refreshonly => true,
      tries       => 3,
      try_sleep   => 10
    }
  }
}
