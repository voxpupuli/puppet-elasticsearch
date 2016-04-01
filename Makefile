DISTRO ?= ubuntu-server-1404-x64
PE ?= false
PE_VER ?= 2015.3.3

.vendor:
	bundle install --path .vendor

.PHONY: clean
clean:
	bundle exec rake spec_clean
	bundle exec rake artifacts:clean
	rm -rf .bundle .vendor

.PHONY: test-intake
test-intake: test-docs test-rspec

.PHONY: test-acceptance
test-acceptance: .vendor
	BEAKER_PE_DIR=spec/fixtures/artifacts \
		BEAKER_PE_VER=$(PE_VER) \
		BEAKER_IS_PE=$(PE) \
		BEAKER_set=$(DISTRO) \
		bundle exec rake beaker

.PHONY: test-integration
test-integration: .vendor
	BEAKER_PE_DIR=spec/fixtures/artifacts \
		BEAKER_PE_VER=$(PE_VER) \
		BEAKER_IS_PE=$(PE) \
		BEAKER_set=$(DISTRO) \
		bundle exec rake beaker:integration

.PHONY: test-docs
test-docs: .vendor
	bundle exec rake parse_doc

.PHONY: test-rspec
test-rspec: .vendor
	bundle exec rake lint
	bundle exec rake validate
	bundle exec rake spec_verbose
