# Managed by modulesync - DO NOT EDIT
# https://voxpupuli.org/docs/updating-files-managed-with-modulesync/

source ENV['GEM_SOURCE'] || 'https://rubygems.org'

group :test do
  gem 'voxpupuli-test', '~> 11.0',  :require => false
  gem 'puppet_metadata', '~> 5.0',  :require => false
  gem 'bcrypt',                     :require => false
  gem 'webmock',                    :require => false
end

group :development do
  gem 'guard-rake',               :require => false
  gem 'overcommit', '>= 0.39.1',  :require => false
end

group :system_tests do
  gem 'voxpupuli-acceptance', '~> 3.5',  :require => false
  gem 'bcrypt',                          :require => false
  gem 'rspec-retry',                     :require => false
  gem 'simp-beaker-helpers',             :require => false
end

group :release do
  gem 'voxpupuli-release', '~> 4.0',  :require => false
end

gem 'rake', :require => false

gem 'openvox', ENV.fetch('OPENVOX_GEM_VERSION', [">= 7", "< 9"]), :require => false, :groups => [:test]

# vim: syntax=ruby
