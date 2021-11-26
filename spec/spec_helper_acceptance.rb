# frozen_string_literal: true

# Managed by modulesync - DO NOT EDIT
# https://voxpupuli.org/docs/updating-files-managed-with-modulesync/

require 'voxpupuli/acceptance/spec_helper_acceptance'

configure_beaker

Dir['./spec/support/acceptance/**/*.rb'].sort.each { |f| require f }
