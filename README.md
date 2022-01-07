# Elasticsearch Puppet Module
[![Build Status](https://github.com/voxpupuli/puppet-elasticsearch/workflows/CI/badge.svg)](https://github.com/voxpupuli/puppet-elasticsearch/actions?query=workflow%3ACI)
[![Release](https://github.com/voxpupuli/puppet-elasticsearch/actions/workflows/release.yml/badge.svg)](https://github.com/voxpupuli/puppet-elasticsearch/actions/workflows/release.yml)
[![Puppet Forge](https://img.shields.io/puppetforge/v/puppet/elasticsearch.svg)](https://forge.puppetlabs.com/puppet/elasticsearch)
[![Puppet Forge - downloads](https://img.shields.io/puppetforge/dt/puppet/elasticsearch.svg)](https://forge.puppetlabs.com/puppet/elasticsearch)
[![Puppet Forge - endorsement](https://img.shields.io/puppetforge/e/puppet/elasticsearch.svg)](https://forge.puppetlabs.com/puppet/elasticsearch)
[![Puppet Forge - scores](https://img.shields.io/puppetforge/f/puppet/elasticsearch.svg)](https://forge.puppetlabs.com/puppet/elasticsearch)
[![puppetmodule.info docs](http://www.puppetmodule.info/images/badge.png)](http://www.puppetmodule.info/m/puppet-elasticsearch)
[![Apache-2 License](https://img.shields.io/github/license/voxpupuli/puppet-elasticsearch.svg)](LICENSE)
[![Donated by Elastic](https://img.shields.io/badge/donated%20by-Elastic-fb7047.svg)](#transfer-notice)

#### Table of Contents

1. [Module description - What the module does and why it is useful](#module-description)
2. [Setup - The basics of getting started with Elasticsearch](#setup)
  * [The module manages the following](#the-module-manages-the-following)
  * [Requirements](#requirements)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Advanced features - Extra information on advanced usage](#advanced-features)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
6. [Limitations - OS compatibility, etc.](#limitations)
7. [Development - Guide for contributing to the module](#development)
8. [Support - When you need help with this module](#support)
9. [Transfer Notice](#transfer-notice)

## Module description

This module sets up [Elasticsearch](https://www.elastic.co/overview/elasticsearch/) instances with additional resource for plugins, templates, and more.

This module is actively tested against Elasticsearch 2.x, 5.x, and 6.x.

# WARNING: The 7.x major release of this module contains breaking changes!

In order to simplify the management of Elasticsearch moving forward, and add support for both Elasticsearch 6.x and 7.x, support for
running multiple instances of Elasticsearch has been removed.

This module also does not currently handle the migration from the instance based configuration to the new single deployment model.
Therefore in-place upgrades from version 6.x of this module to 7.x, or migrations from multi-instance to single deployment is not currently supported.
We hope to add support for this in a future release.

Therefore please ensure that you test this major release in your environment before using it in production!

## Setup

### The module manages the following

* Elasticsearch repository files.
* Elasticsearch package.
* Elasticsearch configuration file.
* Elasticsearch service.
* Elasticsearch plugins.
* Elasticsearch snapshot repositories.
* Elasticsearch templates.
* Elasticsearch ingest pipelines.
* Elasticsearch index settings.
* Elasticsearch users, roles, and certificates.
* Elasticsearch licenses.
* Elasticsearch keystores.

### Requirements

* The [stdlib](https://forge.puppetlabs.com/puppetlabs/stdlib) Puppet library.
* [richardc/datacat](https://forge.puppetlabs.com/richardc/datacat)
* [Augeas](http://augeas.net/)
* [puppetlabs-java_ks](https://forge.puppetlabs.com/puppetlabs/java_ks) for certificate management (optional).

Beginning with Elasticsearch 7.0.0, a Java JDK has been bundled as part of the elasticsearch package.
However there still needs to be a version of Java present on the system being managed in order for Puppet to be able to run various utilities.
We recommend managing your Java installation with the [puppetlabs-java](https://forge.puppetlabs.com/puppetlabs/java) module.

#### Repository management

When using the repository management, the following module dependencies are required:

* General: [Puppet/elastic_stack](https://forge.puppet.com/puppet/elastic_stack)
* Debian/Ubuntu: [Puppetlabs/apt](https://forge.puppetlabs.com/puppetlabs/apt)
* openSUSE/SLES: [puppet/zypprepo](https://forge.puppetlabs.com/puppet/zypprepo)

### Beginning with Elasticsearch

Declare the top-level `elasticsearch` class (managing repositories) and set up an instance:

```puppet
include ::java

class { 'elasticsearch': }
```

## Usage

### Main class

Most top-level parameters in the `elasticsearch` class are set to reasonable defaults.
The following are some parameters that may be useful to override:

#### Install a specific version

```puppet
class { 'elasticsearch':
  version => '7.9.3'
}
```

Note: This will only work when using the repository.

#### Automatically restarting the service (default set to false)

By default, the module will not restart Elasticsearch when the configuration file, package, or plugins change.
This can be overridden globally with the following option:

```puppet
class { 'elasticsearch':
  restart_on_change => true
}
```

Or controlled with the more granular options: `restart_config_change`, `restart_package_change`, and `restart_plugin_change.`

#### Automatic upgrades (default set to false)

```puppet
class { 'elasticsearch':
  autoupgrade => true
}
```

#### Removal/Decommissioning

```puppet
class { 'elasticsearch':
  ensure => 'absent'
}
```

#### Install everything but disable service(s) afterwards

```puppet
class { 'elasticsearch':
  status => 'disabled'
}
```

#### API Settings

Some resources, such as `elasticsearch::template`, require communicating with the Elasticsearch REST API.
By default, these API settings are set to:

```puppet
class { 'elasticsearch':
  api_protocol            => 'http',
  api_host                => 'localhost',
  api_port                => 9200,
  api_timeout             => 10,
  api_basic_auth_username => undef,
  api_basic_auth_password => undef,
  api_ca_file             => undef,
  api_ca_path             => undef,
  validate_tls            => true,
}
```

Each of these can be set at the top-level `elasticsearch` class and inherited for each resource or overridden on a per-resource basis.

#### Dynamically Created Resources

This module supports managing all of its defined types through top-level parameters to better support Hiera and Puppet Enterprise.
For example, to manage an index template directly from the `elasticsearch` class:

```puppet
class { 'elasticsearch':
  templates => {
    'logstash' => {
      'content' => {
        'template' => 'logstash-*',
        'settings' => {
          'number_of_replicas' => 0
        }
      }
    }
  }
}
```
### Plugins

This module can help manage [a variety of plugins](http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/modules-plugins.html#known-plugins).
Note that `module_dir` is where the plugin will install itself to and must match that published by the plugin author; it is not where you would like to install it yourself.

#### From an official repository

```puppet
elasticsearch::plugin { 'x-pack': }
```

#### From a custom url

```puppet
elasticsearch::plugin { 'jetty':
  url => 'https://oss-es-plugins.s3.amazonaws.com/elasticsearch-jetty/elasticsearch-jetty-1.2.1.zip'
}
```

#### Using a proxy

You can also use a proxy if required by setting the `proxy_host` and `proxy_port` options:
```puppet
elasticsearch::plugin { 'lmenezes/elasticsearch-kopf',
  proxy_host => 'proxy.host.com',
  proxy_port => 3128
}
```

Proxies that require usernames and passwords are similarly supported with the `proxy_username` and `proxy_password` parameters.

Plugin name formats that are supported include:

* `elasticsearch/plugin/version` (for official elasticsearch plugins downloaded from download.elastic.co)
* `groupId/artifactId/version` (for community plugins downloaded from maven central or OSS Sonatype)
* `username/repository` (for site plugins downloaded from github master)

#### Upgrading plugins

When you specify a certain plugin version, you can upgrade that plugin by specifying the new version.

```puppet
elasticsearch::plugin { 'elasticsearch/elasticsearch-cloud-aws/2.1.1': }
```

And to upgrade, you would simply change it to

```puppet
elasticsearch::plugin { 'elasticsearch/elasticsearch-cloud-aws/2.4.1': }
```

Please note that this does not work when you specify 'latest' as a version number.

#### ES 6.x and 7.x official plugins
For the Elasticsearch commercial plugins you can refer them to the simple name.

See [Plugin installation](https://www.elastic.co/guide/en/elasticsearch/plugins/current/installation.html) for more details.

### Scripts

Installs [scripts](http://www.elastic.co/guide/en/elasticsearch/reference/current/modules-scripting.html) to be used by Elasticsearch.
These scripts are shared across all defined instances on the same host.

```puppet
elasticsearch::script { 'myscript':
  ensure => 'present',
  source => 'puppet:///path/to/my/script.groovy'
}
```

Script directories can also be recursively managed for large collections of scripts:

```puppet
elasticsearch::script { 'myscripts_dir':
  ensure  => 'directory,
  source  => 'puppet:///path/to/myscripts_dir'
  recurse => 'remote',
}
```

### Templates

By default templates use the top-level `elasticsearch::api_*` settings to communicate with Elasticsearch.
The following is an example of how to override these settings:

```puppet
elasticsearch::template { 'templatename':
  api_protocol            => 'https',
  api_host                => $::ipaddress,
  api_port                => 9201,
  api_timeout             => 60,
  api_basic_auth_username => 'admin',
  api_basic_auth_password => 'adminpassword',
  api_ca_file             => '/etc/ssl/certs',
  api_ca_path             => '/etc/pki/certs',
  validate_tls            => false,
  source                  => 'puppet:///path/to/template.json',
}
```

#### Add a new template using a file

This will install and/or replace the template in Elasticsearch:

```puppet
elasticsearch::template { 'templatename':
  source => 'puppet:///path/to/template.json',
}
```

#### Add a new template using content

This will install and/or replace the template in Elasticsearch:

```puppet
elasticsearch::template { 'templatename':
  content => {
    'template' => "*",
    'settings' => {
      'number_of_replicas' => 0
    }
  }
}
```

Plain JSON strings are also supported.

```puppet
elasticsearch::template { 'templatename':
  content => '{"template":"*","settings":{"number_of_replicas":0}}'
}
```

#### Delete a template

```puppet
elasticsearch::template { 'templatename':
  ensure => 'absent'
}
```

### Ingestion Pipelines

Pipelines behave similar to templates in that their contents can be controlled
over the Elasticsearch REST API with a custom Puppet resource.
API parameters follow the same rules as templates (those settings can either be
controlled at the top-level in the `elasticsearch` class or set per-resource).

#### Adding a new pipeline

This will install and/or replace an ingestion pipeline in Elasticsearch
(ingestion settings are compared against the present configuration):

```puppet
elasticsearch::pipeline { 'addfoo':
  content => {
    'description' => 'Add the foo field',
    'processors' => [{
      'set' => {
        'field' => 'foo',
        'value' => 'bar'
      }
    }]
  }
}
```

#### Delete a pipeline

```puppet
elasticsearch::pipeline { 'addfoo':
  ensure => 'absent'
}
```


### Index Settings

This module includes basic support for ensuring an index is present or absent
with optional index settings.
API access settings follow the pattern previously mentioned for templates.

#### Creating an index

At the time of this writing, only index settings are supported.
Note that some settings (such as `number_of_shards`) can only be set at index
creation time.

```puppet
elasticsearch::index { 'foo':
  settings => {
    'index' => {
      'number_of_replicas' => 0
    }
  }
}
```

#### Delete an index

```puppet
elasticsearch::index { 'foo':
  ensure => 'absent'
}
```

### Snapshot Repositories

By default snapshot_repositories use the top-level `elasticsearch::api_*` settings to communicate with Elasticsearch.
The following is an example of how to override these settings:

```puppet
elasticsearch::snapshot_repository { 'backups':
  api_protocol            => 'https',
  api_host                => $::ipaddress,
  api_port                => 9201,
  api_timeout             => 60,
  api_basic_auth_username => 'admin',
  api_basic_auth_password => 'adminpassword',
  api_ca_file             => '/etc/ssl/certs',
  api_ca_path             => '/etc/pki/certs',
  validate_tls            => false,
  location                => '/backups',
}
```

#### Delete a snapshot repository

```puppet
elasticsearch::snapshot_repository { 'backups':
  ensure   => 'absent',
  location => '/backup'
}
```

### Connection Validator

This module offers a way to make sure an instance has been started and is up and running before
doing a next action. This is done via the use of the `es_instance_conn_validator` resource.
```puppet
es_instance_conn_validator { 'myinstance' :
  server => 'es.example.com',
  port   => '9200',
}
```

A common use would be for example :

```puppet
class { 'kibana4' :
  require => Es_Instance_Conn_Validator['myinstance'],
}
```

### Package installation

There are two different ways of installing Elasticsearch:

#### Repository


##### Choosing an Elasticsearch major version

This module uses the `elastic/elastic_stack` module to manage package repositories. Because there is a separate repository for each major version of the Elastic stack, selecting which version to configure is necessary to change the default repository value, like this:


```puppet
class { 'elastic_stack::repo':
  version => 6,
}

class { 'elasticsearch':
  version => '6.8.12',
}
```

This module defaults to the upstream package repositories, which as of Elasticsearch 6.3, includes X-Pack. In order to use the purely OSS (open source) package and repository, the appropriate `oss` flag must be set on the `elastic_stack::repo` and `elasticsearch` classes:

```puppet
class { 'elastic_stack::repo':
  oss => true,
}

class { 'elasticsearch':
  oss => true,
}
```

##### Manual repository management

You may want to manage repositories manually. You can disable automatic repository management like this:

```puppet
class { 'elasticsearch':
  manage_repo => false,
}
```

#### Remote package source

When a repository is not available or preferred you can install the packages from a remote source:

##### http/https/ftp

```puppet
class { 'elasticsearch':
  package_url => 'https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.4.2.deb',
  proxy_url   => 'http://proxy.example.com:8080/',
}
```

Setting `proxy_url` to a location will enable download using the provided proxy
server.
This parameter is also used by `elasticsearch::plugin`.
Setting the port in the `proxy_url` is mandatory.
`proxy_url` defaults to `undef` (proxy disabled).

##### puppet://
```puppet
class { 'elasticsearch':
  package_url => 'puppet:///path/to/elasticsearch-1.4.2.deb'
}
```

##### Local file

```puppet
class { 'elasticsearch':
  package_url => 'file:/path/to/elasticsearch-1.4.2.deb'
}
```

### JVM Configuration

When configuring Elasticsearch's memory usage, you can modify it by setting `jvm_options`:

```puppet
class { 'elasticsearch':
  jvm_options => [
    '-Xms4g',
    '-Xmx4g'
  ]
}
```

### Service management

Currently only the basic SysV-style [init](https://en.wikipedia.org/wiki/Init) and [Systemd](http://en.wikipedia.org/wiki/Systemd) service providers are supported, but other systems could be implemented as necessary (pull requests welcome).

#### Defaults File

The *defaults* file (`/etc/defaults/elasticsearch` or `/etc/sysconfig/elasticsearch`) for the Elasticsearch service can be populated as necessary.
This can either be a static file resource or a simple key value-style  [hash](http://docs.puppetlabs.com/puppet/latest/reference/lang_datatypes.html#hashes) object, the latter being particularly well-suited to pulling out of a data source such as Hiera.

##### File source

```puppet
class { 'elasticsearch':
  init_defaults_file => 'puppet:///path/to/defaults'
}
```
##### Hash representation

```puppet
$config_hash = {
  'ES_HEAP_SIZE' => '30g',
}

class { 'elasticsearch':
  init_defaults => $config_hash
}
```

Note: `init_defaults` hash can be passed to the main class and to the instance.

## Advanced features

### Security

File-based users, roles, and certificates can be managed by this module.

**Note**: If you are planning to use these features, it is *highly recommended* you read the following documentation to understand the caveats and extent of the resources available to you.

#### Roles

Roles in the file realm can be managed using the `elasticsearch::role` type.
For example, to create a role called `myrole`, you could use the following resource:

```puppet
elasticsearch::role { 'myrole':
  privileges => {
    'cluster' => [ 'monitor' ],
    'indices' => [{
      'names'      => [ '*' ],
      'privileges' => [ 'read' ],
    }]
  }
}
```

This role would grant users access to cluster monitoring and read access to all indices.
See the [Security](https://www.elastic.co/guide/en/elasticsearch/reference/current/elasticsearch-security.html) documentation for your version to determine what `privileges` to use and how to format them (the Puppet hash representation will simply be translated into yaml.)

**Note**: The Puppet provider for `elasticsearch_user` has fine-grained control over the `roles.yml` file and thus will leave the default roles in-place.
If you would like to explicitly purge the default roles (leaving only roles managed by puppet), you can do so by including the following in your manifest:

```puppet
resources { 'elasticsearch_role':
  purge => true,
}
```

##### Mappings

Associating mappings with a role for file-based management is done by passing an array of strings to the `mappings` parameter of the `elasticsearch::role` type.
For example, to define a role with mappings:

```puppet
elasticsearch::role { 'logstash':
  mappings   => [
    'cn=group,ou=devteam',
  ],
  privileges => {
    'cluster' => 'manage_index_templates',
    'indices' => [{
      'names'      => ['logstash-*'],
      'privileges' => [
        'write',
        'delete',
        'create_index',
      ],
    }],
  },
}
```

If you'd like to keep the mappings file purged of entries not under Puppet's control, you should use the following `resources` declaration because mappings are a separate low-level type:

```puppet
resources { 'elasticsearch_role_mapping':
  purge => true,
}
```

#### Users

Users can be managed using the `elasticsearch::user` type.
For example, to create a user `mysuser` with membership in `myrole`:

```puppet
elasticsearch::user { 'myuser':
  password => 'mypassword',
  roles    => ['myrole'],
}
```

The `password` parameter will also accept password hashes generated from the `esusers`/`users` utility and ensure the password is kept in-sync with the Shield `users` file for all Elasticsearch instances.

```puppet
elasticsearch::user { 'myuser':
  password => '$2a$10$IZMnq6DF4DtQ9c4sVovgDubCbdeH62XncmcyD1sZ4WClzFuAdqspy',
  roles    => ['myrole'],
}
```

**Note**: When using the `esusers`/`users` provider (the default for plaintext passwords), Puppet has no way to determine whether the given password is in-sync with the password hashed by Elasticsearch.
In order to work around this, the `elasticsearch::user` resource has been designed to accept refresh events in order to update password values.
This is not ideal, but allows you to instruct the resource to change the password when needed.
For example, to update the aforementioned user's password, you could include the following your manifest:

```puppet
notify { 'update password': } ~>
elasticsearch::user { 'myuser':
  password => 'mynewpassword',
  roles    => ['myrole'],
}
```

#### Certificates

SSL/TLS can be enabled by providing the appropriate class params with paths to the certificate and private key files, and a password for the keystore.

```puppet
class { 'elasticsearch' :
  ssl                  => true,
  ca_certificate       => '/path/to/ca.pem',
  certificate          => '/path/to/cert.pem',
  private_key          => '/path/to/key.pem',
  keystore_password    => 'keystorepassword',
}
```

**Note**: Setting up a proper CA and certificate infrastructure is outside the scope of this documentation, see the aforementioned security guide for more information regarding the generation of these certificate files.

The module will set up a keystore file for the node to use and set the relevant options in `elasticsearch.yml` to enable TLS/SSL using the certificates and key provided.

#### System Keys

System keys can be passed to the module, where they will be placed into individual instance configuration directories.
This can be set at the `elasticsearch` class and inherited across all instances:

```puppet
class { 'elasticsearch':
  system_key => 'puppet:///path/to/key',
}
```

### Licensing

If you use the aforementioned security features, you may need to install a user license to leverage particular features outside of a trial license.
This module can handle installation of licenses without the need to write custom `exec` or `curl` code to install license data.

You may instruct the module to install a license through the `elasticsearch::license` parameter:

```puppet
class { 'elasticsearch':
  license => $license,
}
```

The `license` parameter will accept either a Puppet hash representation of the license file json or a plain json string that will be parsed into a native Puppet hash.
Although dependencies are automatically created to ensure that the Elasticsearch service is listening and ready before API calls are made, you may need to set the appropriate `api_*` parameters to ensure that the module can interact with the Elasticsearch API over the appropriate port, protocol, and with sufficient user rights to install the license.

The native provider for licenses will _not_ print license signatures as part of Puppet's changelog to ensure that sensitive values are not included in console output or Puppet reports.
Any fields present in the `license` parameter that differ from the license installed in a cluster will trigger a flush of the resource and new `POST` to the Elasticsearch API with the license content, though the sensitive `signature` field is not compared as it is not returned from the Elasticsearch licensing APIs.

### Data directories

There are several different ways of setting data directories for Elasticsearch.
In every case the required configuration options are placed in the `elasticsearch.yml` file.

#### Default

By default we use:

    /var/lib/elasticsearch

Which mirrors the upstream defaults.

#### Single global data directory

It is possible to override the default data directory by specifying the `datadir` param:

```puppet
class { 'elasticsearch':
  datadir => '/var/lib/elasticsearch-data'
}
```

#### Multiple Global data directories

It's also possible to specify multiple data directories using the `datadir` param:

```puppet
class { 'elasticsearch':
  datadir => [ '/var/lib/es-data1', '/var/lib/es-data2']
}
```

See [the Elasticsearch documentation](https://www.elastic.co/guide/en/elasticsearch/reference/current/modules-node.html#max-local-storage-nodes) for additional information regarding this configuration.

### Elasticsearch configuration

The `config` option can be used to provide additional configuration options to Elasticsearch.

#### Configuration writeup

The `config` hash can be written in 2 different ways:

##### Full hash writeup

Instead of writing the full hash representation:

```puppet
class { 'elasticsearch':
  config                 => {
   'cluster'             => {
     'name'              => 'ClusterName',
     'routing'           => {
        'allocation'     => {
          'awareness'    => {
            'attributes' => 'rack'
          }
        }
      }
    }
  }
}
```

##### Short hash writeup

```puppet
class { 'elasticsearch':
  config => {
    'cluster' => {
      'name' => 'ClusterName',
      'routing.allocation.awareness.attributes' => 'rack'
    }
  }
}
```

#### Keystore Settings

Recent versions of Elasticsearch include the [elasticsearch-keystore](https://www.elastic.co/guide/en/elasticsearch/reference/current/secure-settings.html) utility to create and manage the `elasticsearch.keystore` file which can store sensitive values for certain settings.
The settings and values for this file can be controlled by this module.
Settings follow the behavior of the `config` parameter for the top-level Elasticsearch class and `elasticsearch::instance` defined types.
That is, you may define keystore settings globally, and all values will be merged with instance-specific settings for final inclusion in the `elasticsearch.keystore` file.
Note that each hash key is passed to the `elasticsearch-keystore` utility in a straightforward manner, so you should specify the hash passed to `secrets` in flattened form (that is, without full nested hash representation).

For example, to define cloud plugin credentials for all instances:

```puppet
class { 'elasticsearch':
  secrets => {
    'cloud.aws.access_key' => 'AKIA....',
    'cloud.aws.secret_key' => 'AKIA....',
  }
}
```

##### Purging Secrets

By default, if a secret setting exists on-disk that is not present in the `secrets` hash, this module will leave it intact.
If you prefer to keep only secrets in the keystore that are specified in the `secrets` hash, use the `purge_secrets` boolean parameter either on the `elasticsearch` class to set it globally or per-instance.

##### Notifying Services

Any changes to keystore secrets will notify running elasticsearch services by respecting the `restart_on_change` and `restart_config_change` parameters.

## Reference

Class parameters are available in [the auto-generated documentation
pages](https://elastic.github.io/puppet-elasticsearch/puppet_classes/elasticsearch.html).
Autogenerated documentation for types, providers, and ruby helpers is also
available on the same documentation site.

## Limitations

This module is built upon and tested against the versions of Puppet listed in
the metadata.json file (i.e. the listed compatible versions on the Puppet
Forge).

The module has been tested on:

* Amazon Linux 1/2
* Debian 8/9/10
* CentOS 7/8
* OracleLinux 7/8
* Ubuntu 16.04, 18.04, 20.04
* SLES 12

Testing on other platforms has been light and cannot be guaranteed.

## Development

Please see the [CONTRIBUTING.md](https://github.com/voxpupuli/puppet-elasticsearch/blob/master/.github/CONTRIBUTING.md) file for instructions regarding development environments and testing.

## Support

The Puppet Elasticsearch module is community supported and not officially supported by Elastic Support.

## Transfer Notice

This module was originally authored by [Elastic](https://www.elastic.co).
The maintainer preferred that Vox Pupuli take ownership of the module for future improvement and maintenance.
Existing pull requests and issues were transferred over, please fork and continue to contribute here instead of Elastic.
