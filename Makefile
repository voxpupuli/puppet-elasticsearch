DISTRO ?= ubuntu-server-1404-x64
PE ?= false
PE_VER ?= 3.8.0

.vendor:
	bundle update || true
	bundle install --path .vendor

.PHONY: fixtures
fixtures: .vendor
	bundle exec rake artifacts:prep

.PHONY: clean
clean:
	bundle exec rake spec_clean
	bundle exec rake artifacts:clean
	rm -rf .bundle .vendor

.PHONY: test-intake
test-intake: test-docs test-rspec

.PHONY: test-acceptance
test-acceptance: .vendor fixtures
	BEAKER_PE_DIR=spec/fixtures/artifacts \
		BEAKER_PE_VER=$(PE_VER) \
		BEAKER_IS_PE=$(PE) \
		BEAKER_set=$(DISTRO) \
		bundle exec rspec \
			--require ci/reporter/rspec \
			--format CI::Reporter::RSpecFormatter \
			spec/acceptance/*_spec.rb

.PHONY: test-integration
test-integration: .vendor fixtures
	BEAKER_PE_DIR=spec/fixtures/artifacts \
		BEAKER_PE_VER=$(PE_VER) \
		BEAKER_IS_PE=$(PE) \
		BEAKER_set=$(DISTRO) \
		bundle exec rspec \
			--require ci/reporter/rspec \
			--format CI::Reporter::RSpecFormatter \
			spec/acceptance/integration001.rb

.PHONY: test-docs
test-docs: .vendor
	bundle exec rake parse_doc

.PHONY: test-rspec
test-rspec: .vendor
	bundle exec rake lint
	bundle exec rake validate
	bundle exec rake spec \
		SPEC_OPTS='--format documentation --require ci/reporter/rspec --format CI::Reporter::RSpecFormatter'
