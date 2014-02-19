# puppet-elasticsearch

A Puppet module for managing [elasticsearch nodes](http://www.elasticsearch.org/).

[![Build Status](https://travis-ci.org/elasticsearch/puppet-elasticsearch.png?branch=master)](https://travis-ci.org/elasticsearch/puppet-elasticsearch)

## Requirements

* Puppet 2.7.x or better.
* The [stdlib](https://forge.puppetlabs.com/puppetlabs/stdlib) Puppet library.

Optional:
* The [apt](http://forge.puppetlabs.com/puppetlabs/apt) Puppet library when using repo management on Debian/Ubuntu.

## Usage examples

Installation, make sure service is running and will be started at boot time:

     class { 'elasticsearch': }

Install a certain version:

     class { 'elasticsearch':
       version => '0.90.3'
     }

This assumes an elasticsearch package is already available to your distribution's package manager. To install it in a different way:

To download from http/https/ftp source:

     class { 'elasticsearch':
       package_url => 'https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-0.90.7.deb'
     }

To download from a puppet:// source:

     class { 'elasticsearch':
       package_url => 'puppet:///path/to/elasticsearch-0.90.7.deb'
     }

Or use a local file source:

     class { 'elasticsearch':
       package_url => 'file:/path/to/elasticsearch-0.90.7.deb'
     }

Automatic upgrade of the software ( default set to false ):

     class { 'elasticsearch':
       autoupgrade => true
     }

Removal/decommissioning:

     class { 'elasticsearch':
       ensure => 'absent'
     }

Install everything but disable service(s) afterwards:

     class { 'elasticsearch':
       status => 'disabled'
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


## Manage templates

### Add a new template

This will install and/or replace the template in Elasticearch

     elasticsearch::template { 'templatename':
       file => 'puppet:///path/to/template.json'
     }

### Delete a template

     elasticsearch::template { 'templatename':
       ensure => 'absent'
     }

### Host

  Default it uses localhost:9200 as host. you can change this with the 'host' and 'port' variables

     elasticsearch::template { 'templatename':
       host => $::ipaddress,
       port => 9200
     }

## Bindings / clients

Install a variety of [clients/bindings](http://www.elasticsearch.org/guide/clients/):

### Python

     elasticsearch::python { 'rawes': }

### Ruby

     elasticsearch::ruby { 'elasticsearch': }

## Plugins

Install [a variety of plugins](http://www.elasticsearch.org/guide/plugins/):

### From official repository:

     elasticsearch::plugin{'mobz/elasticsearch-head':
       module_dir => 'head'
     }

### From custom url:

     elasticsearch::plugin{ 'elasticsearch-jetty':
       module_dir => 'jetty',
       url        => 'https://oss-es-plugins.s3.amazonaws.com/elasticsearch-jetty/elasticsearch-jetty-0.90.0.zip'
     }

## Java Install

Most sites will manage Java seperately; however, this module can attempt to install Java as well.

     class { 'elasticsearch':
       java_install => true
     }

Specify a particular Java package (version) to be installed:

     class { 'elasticsearch':
       java_install => true,
       java_package => 'packagename'
     }

## Repository management

Most sites will manage repositories seperately; however, this module can manage the repository for you.

    class { 'elasticsearch':
      manage_repo  => true,
      repo_version => '1.0',
    }

Note: When using this on Debian/Ubuntu you will need to add the [Puppetlabs/apt](http://forge.puppetlabs.com/puppetlabs/apt) module to your modules.

## Service Management

Currently only the basic SysV-style [init](https://en.wikipedia.org/wiki/Init) service provider is supported but other systems could be implemented as necessary (pull requests welcome).

### init

#### Defaults File

The *defaults* file (`/etc/defaults/elasticsearch` or `/etc/sysconfig/elasticsearch`) for the Logstash service can be populated as necessary. This can either be a static file resource or a simple key value-style  [hash](http://docs.puppetlabs.com/puppet/latest/reference/lang_datatypes.html#hashes) object, the latter being particularly well-suited to pulling out of a data source such as Hiera.

##### file source

     class { 'elasticsearch':
       init_defaults_file => 'puppet:///path/to/defaults'
     }

##### hash representation

     $config_hash = {
       'ES_USER' => 'elasticsearch',
       'ES_GROUP' => 'elasticsearch',
     }

     class { 'elasticsearch':
       init_defaults => $config_hash
     }

## Support

Need help? Join us in [#elasticsearch](https://webchat.freenode.net?channels=%23elasticsearch) on Freenode IRC or subscribe to the [elasticsearch@googlegroups.com](https://groups.google.com/forum/#!forum/elasticsearch) mailing list.
