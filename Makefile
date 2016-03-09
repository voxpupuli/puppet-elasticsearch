DISTRO ?= debian-8-x64

.vendor:
	bundle install --path .vendor

.PHONY: fixtures
fixtures: .vendor
	bundle exec rake spec_prep

.PHONY: clean
clean:
	bundle exec rake spec_clean
	rm -rf .bundle .vendor

.PHONY: test-intake
test-intake: test-docs test-rspec

.PHONY: test-acceptance
test-acceptance: .vendor fixtures
	BEAKER_set=$(DISTRO) bundle exec rspec --require ci/reporter/rspec --format CI::Reporter::RSpecFormatter spec/acceptance/*_spec.rb

.PHONY: test-integration
test-integration: .vendor fixtures
	BEAKER_set=$(DISTRO) bundle exec rspec --require ci/reporter/rspec --format CI::Reporter::RSpecFormatter spec/acceptance/integration001.rb

.PHONY: test-docs
test-docs: .vendor
	bundle exec rake parse_doc

.PHONY: test-rspec
test-rspec: .vendor
	bundle exec rake lint
	bundle exec rake validate
	bundle exec rake spec SPEC_OPTS='--format documentation --require ci/reporter/rspec --format CI::Reporter::RSpecFormatter'
