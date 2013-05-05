# == Class: elasticsearch::monitoring::sensu
#
# Adds sensu monitoring to elasticsearch hosts
#
#
# === Authors
#
# * Justin Lambert <mailto:jlambert@letsevenup.com>
#
class elasticsearch::monitoring::sensu {

  # Checking ES node and cluster health
  sensu::check { 'es-status':
    handlers    => 'default',
    command     => '/etc/sensu/plugins/check-es-cluster-status.rb',
    standalone  => true,
  }

  # Metrics
  sensu::check { 'es-metrics':
    type        => 'metric',
    handlers    => 'graphite',
    command     => '/etc/sensu/plugins/es-node-graphite.rb',
    standalone  => true,
  }

  sensu::subscription { 'elasticsearch': }

}
