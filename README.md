# puppet-elasticsearch

A puppet module for managing elasticsearch nodes

This module is puppet 3 tested

## Usage

Installation, make sure service is running and will be started at boot time:

     class { 'elasticsearch': }

Removal/decommissioning:

     class { 'elasticsearch':
       ensure => 'absent',
     }

Install everything but disable service(s) afterwards:

     class { 'elasticsearch':
       status => 'disabled',
     }

For the config variable a hash needs to be passed:

     class { 'elasticsearch':
       config                   => {
         'node'                 => {
           'name'               => 'elasticsearch001'
         },
         'index'                => {
           'number_of_replicas' => '0',
           'number_of_shareds'  => '5'
         },
         'network'              => {
           'host'               => $::ipaddress
         }
       }
     }
