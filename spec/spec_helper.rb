require 'rubygems'
require 'puppetlabs_spec_helper/module_spec_helper'

RSpec.configure do |c|
  c.parser = 'future' if ENV['FUTURE_PARSER'] == 'true'
end
