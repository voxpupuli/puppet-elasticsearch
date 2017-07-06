# Set the Linux distribution w/defaults (see spec/acceptance/nodesets)
DISTRO ?= ubuntu-server-1604-x64
BEAKER_set ?= $(DISTRO)
export BEAKER_set

# Export potentially set variables for rake/rspec/beaker
export STRICT_VARIABLES=yes

.DEFAULT_GOAL := vendor

vendor: Gemfile
	bundle install
	touch vendor

.PHONY: clean
clean:
	bundle exec rake spec_clean
	bundle exec rake artifacts:clean
	rm -rf .bundle vendor

.PHONY: clean-logs
clean-logs:
	rm -rf log

.PHONY: release
release: clean-logs
	bundle exec puppet module build

.PHONY: test-intake
test-intake: vendor
	bundle exec rake intake

.PHONY: test-acceptance
test-acceptance: vendor
	bundle exec rake beaker:acceptance

.PHONY: test-integration
test-integration: vendor
	bundle exec rake beaker:integration
