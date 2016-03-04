DISTRO ?= debian-8-x64

bundle: .vendor
.vendor:
	rm *.lock
	bundle install --path .vendor

.PHONY: fixtures
fixtures: bundle
	bundle exec rake spec_prep

.PHONY: clean
clean:
	bundle exec rake spec_clean
	rm -rf .bundle .vendor

.PHONY: test-acceptance
test-acceptance: bundle fixtures
	BEAKER_set=$(DISTRO) bundle exec rspec --require ci/reporter/rspec --format CI::Reporter::RSpecFormatter spec/acceptance/*_spec.rb

.PHONY: test-integration
test-integration: bundle fixtures
	BEAKER_set=$(DISTRO) bundle exec rspec --require ci/reporter/rspec --format CI::Reporter::RSpecFormatter spec/acceptance/integration001.rb

.PHONY: test-docs
test-docs: bundle
	bundle exec rake parse_doc

.PHONY: test-rspec
test-rspec: bundle
	bundle exec rake lint
	bundle exec rake validate
	bundle exec rake spec SPEC_OPTS='--format documentation --require ci/reporter/rspec --format CI::Reporter::RSpecFormatter'
