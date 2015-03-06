source 'https://rubygems.org'

puppetversion = ENV['PUPPET_VERSION']
gem 'ci_reporter_rspec'
gem 'metadata-json-lint', :git => 'https://github.com/nibalizer/metadata-json-lint.git'
gem 'puppet', puppetversion, :require => false
gem 'puppet-lint'
gem 'puppet-syntax'
gem 'puppetlabs_spec_helper', '>= 0.1.0'
gem 'rspec', '~> 3.1'
gem 'rspec-puppet', :git => 'https://github.com/electrical/rspec-puppet.git', :branch => 'rspec3'
gem 'rspec-puppet-facts'
gem 'rspec_junit_formatter'
gem 'webmock'

case RUBY_VERSION
when '1.8.7'
  gem 'rake', '~> 10.1.0'
else
  gem 'rake'
end

group :system_test do
  gem 'beaker', :git => 'https://github.com/electrical/beaker.git', :branch => 'hiera_config'
  gem 'beaker-rspec', :git => 'https://github.com/puppetlabs/beaker-rspec.git', :branch => 'master'
  gem 'docker-api', '~> 1.0'
  gem 'pry'
  gem 'rubysl-securerandom'
end

group :doc_file do
  gem 'puppet-doc-lint'
  gem 'rspec_junit_formatter'
end
