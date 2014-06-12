# Temporary due to https://github.com/rspec/rspec-expectations/issues/573
module Encoding; CompatibilityError = Class.new(StandardError); end if RUBY_VERSION < '1.9'

require 'rubygems'
require 'puppetlabs_spec_helper/module_spec_helper'

RSpec.configure do |c|
  c.parser = 'future' if ENV['FUTURE_PARSER'] == 'true'
end
