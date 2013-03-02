define elasticsearch::template(
  $file    = undef,
  $replace = false,
  $delete  = false,
  $host    = 'localhost',
  $port    = 9200
) {

  Exec {
    path => [ '/bin', '/usr/bin', '/usr/local/bin' ]
  }

  # Can't do a replace and delete at the same time
  if $replace == true and $delete == true {
    fail('Replace and Delete cant be used together')
  }

  exec { 'mkdir -p /etc/elasticsearch/templates':
    cwd     => '/',
    creates => '/etc/elasticsearch/templates'
  }

  # Build up the url
  $es_url = "http://${host}:${port}/_template/${name}"

  if $delete == false {
    # Fail when no file is supplied
    if $file == undef {
      fail('The variable "file" cannot be empty when inserting or updating a template')
    }

    # place the template file in /tmp
    file { "/etc/elasticsearch/templates/elasticsearch-template-${name}.json":
      ensure => present,
      source => $file,
      notify => Exec[ 'insert_template' ]
    }
  }

  if $replace == true or $delete == true {

    $exec_before = $replace ? {
      true  => Exec[ 'insert_template' ],
      false => undef
    }

    # Delete the existing template
    # First check if it exists of course
    exec { 'delete_template':
      command   => "curl -s -XDELETE ${es_url}",
      unless    => "test $(curl -s '${es_url}?pretty=true' | wc -l) -gt 1",
      before    => $exec_before
    }

  }

  # Insert the template if we don't delete an existing one
  # Before inserting we check if a template exists with that same name
  if $delete == false {
    exec { 'insert_template':
      command     => "curl -s -XPUT ${es_url} -d @/etc/elasticsearch/templates/elasticsearch-template-${name}.json",
      unless      => "test $(curl -s '${es_url}?pretty=true' | wc -l) -gt 1",
      refreshonly => true
    }
  }
}
