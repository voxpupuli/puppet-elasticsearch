# Set the Linux distribution w/defaults (see spec/acceptance/nodesets)
DISTRO ?= ubuntu-server-1404-x64
BEAKER_set ?= $(DISTRO)
export BEAKER_set

# Default to installing agent (version 4.x)
PUPPET_INSTALL_TYPE ?= agent

# Set Puppet Enterprise defaults
ifeq ($(PUPPET_INSTALL_TYPE), pe)
	PUPPET_INSTALL_VERSION ?= 2016.1.2
	BEAKER_PE_VER ?= $(PUPPET_INSTALL_VERSION)
	export BEAKER_PE_VER
	BEAKER_IS_PE := true
	export BEAKER_IS_PE
endif

# Export potentially set variables for rake/rspec/beaker
export PUPPET_INSTALL_TYPE
export BEAKER_PE_DIR=spec/fixtures/artifacts
export STRICT_VARIABLES=yes

.DEFAULT_GOAL := .vendor

.vendor: Gemfile
	bundle update || true
	bundle install --path .vendor
	touch .vendor

.PHONY: clean
clean:
	bundle exec rake spec_clean
	bundle exec rake artifacts:clean
	rm -rf .bundle .vendor

.PHONY: clean-logs
clean-logs:
	rm -rf log

.PHONY: release
release: clean-logs
	bundle exec puppet module build

.PHONY: test-intake
test-intake: test-docs test-rspec

.PHONY: test-acceptance
test-acceptance: .vendor
	bundle exec rake beaker:acceptance

.PHONY: test-integration
test-integration: .vendor
	bundle exec rake beaker:integration

.PHONY: test-docs
test-docs: .vendor
	bundle exec rake spec_docs

.PHONY: test-rspec
test-rspec: .vendor
	bundle exec rake lint
	bundle exec rake validate
	bundle exec rake spec_unit
