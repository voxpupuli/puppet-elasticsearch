module Puppet_X
  module Elastic
    class EsVersioning
      def self.opt_flags(package_name, catalog)
        if (es_pkg = catalog.resource("Package[#{package_name}]"))
          es_version = es_pkg.provider.properties[:version] || es_pkg.provider.properties[:ensure]
        else
          raise Puppet::Error, "could not find `Package[#{package_name}]` resource"
        end

        opts = {
          'home' => 'ES_HOME',
          'logs' => 'LOG_DIR',
          'data' => 'DATA_DIR',
          'work' => 'WORK_DIR',
          'conf' => 'CONF_DIR'
        }

        if Puppet::Util::Package.versioncmp(es_version, '5.0.0') >= 0
          opts_flag = 'E'
          opts.delete 'work'
        else
          opts_flag = 'Des.'
        end

        opts.map{ |k, v| "-#{opts_flag}default.path.#{k}=${#{v}}" }.sort
      end
    end
  end
end

