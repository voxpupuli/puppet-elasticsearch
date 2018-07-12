require 'digest/sha1'
require 'rubygems'
require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet_blacksmith/rake_tasks'
require 'net/http'
require 'uri'
require 'fileutils'
require 'rspec/core/rake_task'
require 'puppet-strings'
require 'puppet-strings/tasks'
require 'yaml'
require 'json'
require_relative 'spec/spec_utilities'

ENV['VAULT_APPROLE_ROLE_ID'] ||= '48adc137-3270-fc4a-ae65-1306919d4bb0'
oss_package = ENV['OSS_PACKAGE'] and ENV['OSS_PACKAGE'] == 'true'

# Workaround for certain rspec/beaker versions
module TempFixForRakeLastComment
  def last_comment
    last_description
  end
end
Rake::Application.send :include, TempFixForRakeLastComment

exclude_paths = [
  'pkg/**/*',
  'vendor/**/*',
  'spec/**/*'
]

require 'puppet-lint/tasks/puppet-lint'
require 'puppet-syntax/tasks/puppet-syntax'

PuppetSyntax.exclude_paths = exclude_paths
PuppetSyntax.future_parser = true if ENV['FUTURE_PARSER'] == 'true'

%w[
  80chars
  class_inherits_from_params_class
  class_parameter_defaults
  single_quote_string_with_variable
].each do |check|
  PuppetLint.configuration.send("disable_#{check}")
end

PuppetLint.configuration.ignore_paths = exclude_paths
PuppetLint.configuration.log_format = \
  '%{path}:%{line}:%{check}:%{KIND}:%{message}'

# Append custom cleanup tasks to :clean
task :clean => [
  :'artifact:clean',
  :spec_clean
]

desc 'remove outdated module fixtures'
task :spec_prune do
  mods = 'spec/fixtures/modules'
  fixtures = YAML.load_file '.fixtures.yml'
  fixtures['fixtures']['forge_modules'].each do |mod, params|
    next unless params.is_a? Hash \
      and params.key? 'ref' \
      and File.exist? "#{mods}/#{mod}"

    metadata = JSON.parse(File.read("#{mods}/#{mod}/metadata.json"))
    FileUtils.rm_rf "#{mods}/#{mod}" unless metadata['version'] == params['ref']
  end
end
task :spec_prep => [:spec_prune]

RSpec::Core::RakeTask.new(:spec_verbose) do |t|
  t.pattern = 'spec/{classes,defines,unit,functions,templates}/**/*_spec.rb'
  t.rspec_opts = [
    '--format documentation',
    '--require "ci/reporter/rspec"',
    '--format CI::Reporter::RSpecFormatter',
    '--color'
  ]
end
task :spec_verbose => :spec_prep

RSpec::Core::RakeTask.new(:spec_puppet) do |t|
  t.pattern = 'spec/{classes,defines,functions,templates,unit/facter}/**/*_spec.rb'
  t.rspec_opts = ['--color']
end
task :spec_puppet => :spec_prep

RSpec::Core::RakeTask.new(:spec_unit) do |t|
  t.pattern = 'spec/unit/{type,provider}/**/*_spec.rb'
  t.rspec_opts = ['--color']
end
task :spec_unit => :spec_prep

task :beaker => [:spec_prep]

desc 'Run all linting/unit tests.'
task :intake => [
  :syntax,
  :rubocop,
  :lint,
  :validate,
  :spec_unit,
  :spec_puppet
]

# Plumbing for snapshot tests
desc 'Run the snapshot tests'
RSpec::Core::RakeTask.new('beaker:snapshot', [:filter]) do |task, args|
  task.rspec_opts = ['--color']
  task.pattern = 'spec/acceptance/tests/acceptance_spec.rb'
  task.rspec_opts = []
  task.rspec_opts << '--format documentation' if ENV['CI'].nil?
  task.rspec_opts << "--example '#{args[:filter]}'" if args[:filter]

  ENV['SNAPSHOT_TEST'] = 'true'
  if Rake::Task.task_defined? 'artifact:snapshot:not_found'
    puts 'No snapshot artifacts found, skipping snapshot tests.'
    exit(0)
  end
end

beaker_node_sets.each do |node|
  desc "Run the snapshot tests against the #{node} nodeset"
  task "beaker:#{node}:snapshot", [:filter] => %w[
    spec_prep
    artifact:snapshot:deb
    artifact:snapshot:rpm
  ] do |_task, args|
    ENV['BEAKER_set'] = node
    Rake::Task['beaker:snapshot'].reenable
    Rake::Task['beaker:snapshot'].invoke args[:filter]
  end

  desc "Run acceptance tests against #{node}"
  RSpec::Core::RakeTask.new(
    "beaker:#{node}:acceptance", [:version, :filter] => [:spec_prep]
  ) do |task, args|
    ENV['BEAKER_set'] = node
    args.with_defaults(:version => '6.2.3', :filter => nil)
    task.pattern = 'spec/acceptance/tests/acceptance_spec.rb'
    task.rspec_opts = []
    task.rspec_opts << '--format documentation' if ENV['CI'].nil?
    task.rspec_opts << "--example '#{args[:filter]}'" if args[:filter]
    ENV['ELASTICSEARCH_VERSION'] ||= args[:version]
    Rake::Task['artifact:fetch'].invoke(ENV['ELASTICSEARCH_VERSION'])
  end
end

namespace :artifact do
  desc 'Fetch specific installation artifacts'
  task :fetch, [:version] do |_t, args|
    fetch_archives(
      derive_artifact_urls_for(args[:version])
    )
  end

  namespace :snapshot do
    snapshot_version = JSON.parse(http_retry('https://artifacts-api.elastic.co/v1/versions'))['versions'].reject do |version|
      version.include? 'alpha'
    end.last

    ENV['snapshot_version'] = snapshot_version

    downloads = JSON.parse(http_retry("https://artifacts-api.elastic.co/v1/search/#{snapshot_version}/elasticsearch"))['packages'].select do |pkg, _|
      pkg =~ /(?:deb|rpm)/ and (oss_package ? pkg =~ /oss/ : pkg !~ /oss/)
    end.map do |package, urls|
      [package.split('.').last, urls]
    end.to_h

    # We end up with something like:
    # {
    #   'rpm' => {'url' => 'https://...', 'sha_url' => 'https://...'},
    #   'deb' => {'url' => 'https://...', 'sha_url' => 'https://...'}
    # }
    # Note that checksums are currently broken on the Elastic unified release
    # side; once they start working we can verify them.

    if downloads.empty?
      puts 'No snapshot release available; skipping snapshot download'
      %w[deb rpm].each { |ext| task ext }
      task 'not_found'
    else
      # Download snapshot files
      downloads.each_pair do |extension, urls|
        filename = artifact urls['url']
        checksum = artifact urls['sha_url']
        link = artifact "elasticsearch-snapshot.#{extension}"
        FileUtils.rm link if File.exist? link

        task extension => link
        file link => filename do
          unless File.exist?(link) and File.symlink?(link) \
              and File.readlink(link) == filename
            File.delete link if File.exist? link
            File.symlink File.basename(filename), link
          end
        end

        # file filename => checksum do
        file filename do
          get urls['url'], filename
        end

        task checksum do
          File.delete checksum if File.exist? checksum
          get urls['sha_url'], checksum
        end
      end
    end
  end

  desc 'Purge fetched artifacts'
  task :clean do
    FileUtils.rm_rf(Dir.glob('spec/fixtures/artifacts/*'))
  end
end
