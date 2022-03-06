# Needed for older facter to fetch facts used by the apt module
#
# Might be fixed by: https://github.com/puppetlabs/puppetlabs-apt/pull/1017
if versioncmp(fact('facterversion'), '4.0.0') < 0 and fact('os.name') == 'Ubuntu' {
  package { 'lsb-release':
    ensure => present,
  }
}
