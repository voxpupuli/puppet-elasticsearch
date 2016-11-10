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
        is_post_v5 = post_5? package_name, catalog
        opt_flag = opt_flag is_post_v5

        opts.delete 'work' if is_post_v5

        [opt_flag, opts.map{ |k, v| "-#{opt_flag}default.path.#{k}=${#{v}}" }.sort]
      end

      def self.opt_flag(v5_or_later)
        v5_or_later ? 'E' : 'Des.'
      end

      def self.post_5?(package_name, catalog)
        if (es_pkg = catalog.resource("Package[#{package_name}]"))
          es_version = es_pkg.provider.properties[:version] || es_pkg.provider.properties[:ensure]
        else
          raise Puppet::Error, "could not find `Package[#{package_name}]` resource"
        end

        Puppet::Util::Package.versioncmp(es_version, '5.0.0') >= 0
      end
    end

  end
end
