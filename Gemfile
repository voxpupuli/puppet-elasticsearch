source 'https://rubygems.org'

puppetversion = ENV['PUPPET_VERSION'] || '3.3.2'

group :development, :test do
  gem 'rake'
  gem 'puppet', puppetversion, :require => false
  gem 'puppet-lint'
  gem 'puppetlabs_spec_helper', '>= 0.1.0'
  gem 'rspec-puppet'
  gem 'rspec-system-puppet', '~>2.0'
end
