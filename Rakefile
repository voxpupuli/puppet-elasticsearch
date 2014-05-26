require 'rubygems'
require 'puppetlabs_spec_helper/rake_tasks'

exclude_paths = [
  "pkg/**/*",
  "vendor/**/*",
  "spec/**/*",
]

begin
  require 'puppet-doc-lint/rake_task'
  PuppetDocLint.configuration.ignore_paths = exclude_paths
rescue LoadError
end

begin
  require 'puppet-lint/tasks/puppet-lint'
  require 'puppet-syntax/tasks/puppet-syntax'

  PuppetSyntax.exclude_paths = exclude_paths
  PuppetSyntax.future_parser = true if ENV['FUTURE_PARSER'] == 'true'

  PuppetLint.configuration.send("disable_80chars")
  PuppetLint.configuration.send("disable_class_inherits_from_params_class")
  PuppetLint.configuration.send('disable_class_parameter_defaults')
  PuppetLint.configuration.ignore_paths = exclude_paths
  PuppetLint.configuration.log_format = "%{path}:%{linenumber}:%{check}:%{KIND}:%{message}"
rescue LoadError
end
