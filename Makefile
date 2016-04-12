DISTRO ?= ubuntu-server-1404-x64
PE ?= false

ifeq ($(PE), true)
	PE_VER ?= 3.8.0
	BEAKER_PE_VER := $(PE_VER)
	BEAKER_IS_PE := $(PE)
	export BEAKER_PE_VER
	export BEAKER_IS_PE
endif

.DEFAULT_GOAL := bundle

.PHONY: bundle
bundle:
	bundle update || true
	bundle install --path .vendor

.PHONY: clean
clean:
	bundle exec rake spec_clean
	bundle exec rake artifacts:clean
	rm -rf .bundle .vendor

.PHONY: test-intake
test-intake: test-docs test-rspec

.PHONY: test-acceptance
test-acceptance: bundle
	BEAKER_PE_DIR=spec/fixtures/artifacts \
		BEAKER_set=$(DISTRO) \
		bundle exec rake beaker:acceptance

.PHONY: test-integration
test-integration: bundle
	BEAKER_PE_DIR=spec/fixtures/artifacts \
		BEAKER_PE_VER=$(PE_VER) \
		BEAKER_IS_PE=$(PE) \
		BEAKER_set=$(DISTRO) \
		bundle exec rake beaker:integration

.PHONY: test-docs
test-docs: bundle
	bundle exec rake parse_doc

.PHONY: test-rspec
test-rspec: bundle
	bundle exec rake lint
	bundle exec rake validate
	bundle exec rake spec_verbose
