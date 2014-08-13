require 'rubygems'
require 'puppetlabs_spec_helper/module_spec_helper'

RSpec.configure do |c|
  Puppet.settings[:strict_variables]=true
  Puppet.settings[:ordering]='random'
  c.parser = 'future' if ENV['FUTURE_PARSER'] == 'true'
end
