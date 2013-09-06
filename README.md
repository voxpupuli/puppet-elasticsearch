# puppet-elasticsearch

A puppet module for managing elasticsearch nodes

http://www.elasticsearch.org/

[![Build Status](https://travis-ci.org/elasticsearch/puppet-elasticsearch.png?branch=master)](https://travis-ci.org/elasticsearch/puppet-elasticsearch)

## Usage

Installation, make sure service is running and will be started at boot time:

     class { 'elasticsearch': }

Install a certain version:

     class { 'elasticsearch':
       version => '0.90.3'
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

## Bindings / clients

Install [a variety of python bindings](http://www.elasticsearch.org/guide/clients/):

     elasticsearch::python { "rawes": }


## Plugins

Install [a variety of plugins](http://www.elasticsearch.org/guide/clients/):

### From official repository:

     elasticsearch::plugin{'mobz/elasticsearch-head':
       module_dir => 'head'
     }

### From custom url:

     elasticsearch::plugin{ 'elasticsearch-jetty':
       module_dir => 'elasticsearch-jetty',
       url        => 'https://oss-es-plugins.s3.amazonaws.com/elasticsearch-jetty/elasticsearch-jetty-0.90.0.zip'
     }

