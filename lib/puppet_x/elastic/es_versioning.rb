module Puppet_X
  module Elastic
    class EsVersioning

      DEFAULT_OPTS = {
        'home' => 'ES_HOME',
        'logs' => 'LOG_DIR',
        'data' => 'DATA_DIR',
        'work' => 'WORK_DIR',
        'conf' => 'CONF_DIR'
      }

      def self.opt_flags(package_name, catalog, opts=DEFAULT_OPTS)
        opt_flag = opt_flag(min_version('5.0.0', package_name, catalog))

        opts.delete 'work' if min_version '5.0.0', package_name, catalog
        opts.delete 'home' if min_version '5.4.0', package_name, catalog

        [opt_flag, opts.map{ |k, v| "-#{opt_flag}default.path.#{k}=${#{v}}" }.sort]
      end

      def self.opt_flag(v5_or_later)
        v5_or_later ? 'E' : 'Des.'
      end

      def self.min_version(ver, package_name, catalog)
        Puppet::Util::Package.versioncmp(
          version(package_name, catalog), ver
        ) >= 0
      end

      def self.version(package_name, catalog)
        if (es_pkg = catalog.resource("Package[#{package_name}]"))
          es_pkg.provider.properties[:version] || es_pkg.provider.properties[:ensure]
        else
          raise Puppet::Error, "could not find `Package[#{package_name}]` resource"
        end
      end
    end
  end
end
