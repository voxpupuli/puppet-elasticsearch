source 'https://rubygems.org'

group :rspec do
  puppetversion = ENV['PUPPET_VERSION']
  gem 'puppet', puppetversion, :require => false
  gem 'puppet-lint'
  gem 'rspec-puppet', :git => 'https://github.com/rodjek/rspec-puppet.git'
  gem 'puppetlabs_spec_helper', '>= 0.1.0'
  gem 'rspec_junit_formatter'
end

group :beaker do
  gem 'beaker', :git => 'https://github.com/electrical/beaker.git', :branch => 'docker_test'
	gem 'beaker-rspec'
  gem 'pry'
  gem 'docker-api'
  gem 'rubysl-securerandom'
end

group :doclint do
	gem 'puppet-doc-lint', :git => 'https://github.com/petems/puppet-doc-lint.git'
end
