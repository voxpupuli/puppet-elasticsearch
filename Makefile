# Set the Linux distribution w/defaults (see spec/acceptance/nodesets)
DISTRO ?= ubuntu-server-1604-x64
BEAKER_set ?= $(DISTRO)
export BEAKER_set

# Default to installing agent (version 4.x)
PUPPET_INSTALL_TYPE ?= agent

# Export potentially set variables for rake/rspec/beaker
export PUPPET_INSTALL_TYPE
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
test-intake: .vendor
	bundle exec rake intake

.PHONY: test-acceptance
test-acceptance: .vendor
	bundle exec rake beaker:acceptance

.PHONY: test-integration
test-integration: .vendor
	bundle exec rake beaker:integration
