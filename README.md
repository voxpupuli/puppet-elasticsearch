# puppet-elasticsearch

A puppet module for managing elasticsearch nodes

http://www.elasticsearch.org/

[![Build Status](https://travis-ci.org/electrical/puppet-elasticsearch.png?branch=master)](https://travis-ci.org/electrical/puppet-elasticsearch)

## Usage

Installation, make sure service is running and will be started at boot time:

     class { 'elasticsearch': }

Install a certain version:

     class { 'elasticsearch':
       version => '0.20.6'
     }

No java? No problem.

     class { 'elasticsearch':
	   java_install => true,
	 }

Installing the
[latest and greatest elasticsearch version](http://www.elasticsearch.org/download/)
using a debian package, taking inspiration from
[this gist](https://gist.github.com/wingdspur/2026107)

     $es_version = "0.90.2" # replace version as necessary
     $deb_dir = "/tmp"
     $es_deb_filename = "elasticsearch-${es_version}.deb"
     exec { "wget elasticsearch.deb":
       command => "wget https://download.elasticsearch.org/elasticsearch/elasticsearch/${es_deb_filename}",
       cwd     => "${deb_dir}",
       path    => ["/usr/bin"],
       creates => "${deb_dir}/${es_deb_filename}",
     }
     class { "elasticsearch":
       pkg_source => "${deb_dir}/${es_deb_filename}",
       require    => Exec["wget elasticsearch.deb"],
     }

Removal/decommissioning:

     class { 'elasticsearch':
       ensure => 'absent',
     }

Install everything but disable service(s) afterwards:

     class { 'elasticsearch':
       status => 'disabled',
     }

Disable automated restart of Elasticsearch on config file change:

     class { 'elasticsearch':
       restart_on_change => false
     }

For the config variable a hash needs to be passed:

     class { 'elasticsearch':
       config                   => {
         'node'                 => {
           'name'               => 'elasticsearch001'
         },
         'index'                => {
           'number_of_replicas' => '0',
           'number_of_shards'   => '5'
         },
         'network'              => {
           'host'               => $::ipaddress
         }
       }
     }

Short write up of the config hash is also possible.

Instead of writing the full hash representation:

     class { 'elasticsearch':
       config                 => {
         'cluster'            => {
           'name'             => 'ClusterName',
           'routing'          => {
             'allocation'     => {
               'awareness'    => {
                 'attributes' => 'rack'
               }
             }
           }
         }
       }
     }

You can write the dotted key naming:

     class { 'elasticsearch':
       config => {
         'cluster' => {
           'name' => 'ClusterName',
           'routing.allocation.awareness.attributes' => 'rack'
         }
       }
     }

## Defaults file

You can populate the defaults file ( /etc/defaults/elasticsearch or /etc/sysconfig/elasticsearch )

     class { 'elasticsearch':
       service_settings => { 'ES_USER' => 'elasticsearch', 'ES_GROUP' => 'elasticsearch' }
     }

## Manage templates

### Add a new template

     elasticsearch::template { 'templatename':
       file => 'puppet:///path/to/template.json'
     }

### Delete a template

     elasticsearch::template { 'templatename':
       delete => true
     }

### Replace a template

     elasticsearch::template { 'templatename':
       file    => 'puppet:///path/to/template.json',
       replace => true
     }

### Host

  Default it uses localhost:9200 as host. you can change this with the 'host' and 'port' variables

     elasticsearch::template { 'templatename':
       host => $::ipaddress,
       port => 9200
     }
