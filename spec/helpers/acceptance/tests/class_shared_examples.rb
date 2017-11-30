require 'helpers/acceptance/tests/basic_shared_examples'

shared_examples 'class manifests' do |instance, port|
  include_examples 'basic acceptance tests', instance, port
end
