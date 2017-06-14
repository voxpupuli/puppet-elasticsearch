# rubocop:disable Style/FileName
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

%w(
  80chars
  class_inherits_from_params_class
  class_parameter_defaults
  single_quote_string_with_variable
).each do |check|
  PuppetLint.configuration.send("disable_#{check}")
end

PuppetLint.configuration.ignore_paths = exclude_paths
PuppetLint.configuration.log_format = \
  '%{path}:%{line}:%{check}:%{KIND}:%{message}'

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

RSpec::Core::RakeTask.new(:spec_unit) do |t|
  t.pattern = 'spec/{classes,defines,unit,functions,templates}/**/*_spec.rb'
  t.rspec_opts = ['--color']
end
task :spec_unit => :spec_prep

task :beaker => [:spec_prep, 'artifacts:prep']

desc 'Run all linting/unit tests.'
task :intake => %i[
  metadata_lint
  syntax
  lint
  validate
  spec_unit
]

desc 'Run integration tests'
RSpec::Core::RakeTask.new('beaker:integration') do |c|
  c.pattern = 'spec/integration/integration*.rb'
end
task 'beaker:integration' => [:spec_prep, 'artifacts:snapshot:fetch']

desc 'Run acceptance tests'
RSpec::Core::RakeTask.new('beaker:acceptance') do |c|
  c.pattern = 'spec/acceptance/0*_spec.rb'
end
task 'beaker:acceptance' => [:spec_prep, 'artifacts:prep']

namespace :artifacts do
  desc 'Fetch artifacts for tests'
  task :prep do
    dl_base = 'https://download.elastic.co/elasticsearch/elasticsearch'
    fetch_archives(
      'https://github.com/lmenezes/elasticsearch-kopf/archive/v2.1.1.zip' => \
      'elasticsearch-kopf.zip',
      "#{dl_base}/elasticsearch-2.3.5.deb" => 'elasticsearch-2.3.5.deb',
      "#{dl_base}/elasticsearch-2.3.5.rpm" => 'elasticsearch-2.3.5.rpm'
    )
  end

  namespace :snapshot do
    snapshots = 'https://snapshots.elastic.co/downloads/elasticsearch'
    artifacts = 'spec/fixtures/artifacts'
    build = 'elasticsearch-6.0.0-alpha2-SNAPSHOT'
    %w[deb rpm].each do |ext|
      package = "#{build}.#{ext}"
      local = "#{artifacts}/#{package}"
      checksum = "#{artifacts}/#{package}.sha1"
      link = "#{artifacts}/elasticsearch-snapshot.#{ext}"

      task :fetch => link

      desc "Symlink #{ext} latest snapshot build."
      file link => local do
        unless File.exist?(link) and File.symlink?(link) \
              and File.readlink(link) == package
          File.delete link if File.exist? link
          File.symlink package, link
        end
      end

      desc "Retrieve #{ext} snapshot build."
      file local => checksum do
        if File.exist?(local) and \
           Digest::SHA1.hexdigest(File.read(local)) == File.read(checksum)
          puts "Artifact #{package} already fetched and up-to-date"
        else
          fetch_archives "#{snapshots}/#{package}" => package
        end
      end

      desc "Retrieve #{ext} checksums."
      task checksum do
        File.delete checksum if File.exist? checksum
        fetch_archives "#{snapshots}/#{package}.sha1" => "#{package}.sha1"
      end
    end
  end

  desc 'Purge fetched artifacts'
  task :clean do
    FileUtils.rm_rf(Dir.glob('spec/fixtures/artifacts/*'))
  end
end

def fetch_archives(archives)
  archives.each do |url, orig_fp|
    fp = "spec/fixtures/artifacts/#{orig_fp}"
    if File.exist? fp
      if fp.end_with? 'tar.gz' and !system("tar -tzf #{fp} &>/dev/null")
        puts "Archive #{fp} corrupt, re-fetching..."
        File.delete fp
      else
        puts "Already retrieved intact archive #{fp}..."
        next
      end
    end
    get url, fp
  end
end

def get(url, file_path)
  puts "Fetching #{url}..."
  found = false
  until found
    uri = URI.parse(url)
    conn = Net::HTTP.new(uri.host, uri.port)
    conn.use_ssl = true
    res = conn.get(uri.path)
    if res.header['location']
      url = res.header['location']
    else
      found = true
    end
  end
  File.open(file_path, 'w+') { |fh| fh.write res.body }
end
