require 'digest/sha1'
require 'rubygems'
require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet_blacksmith/rake_tasks'
require 'net/http'
require 'nokogiri'
require 'uri'
require 'fileutils'
require 'rspec/core/rake_task'
require 'open-uri'
require 'puppet-strings'
require 'puppet-strings/tasks'
require 'yaml'
require 'json'
require_relative 'spec/spec_utilities'

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

task :beaker => [:spec_prep, 'artifacts:prep']

desc 'Run all linting/unit tests.'
task :intake => %i[
  syntax
  lint
  validate
  spec_unit
  spec_puppet
]

desc 'Run snapshot tests'
RSpec::Core::RakeTask.new('beaker:snapshot') do |c|
  c.pattern = 'spec/acceptance/snapshot.rb'
end
task 'beaker:snapshot' => [
  'artifacts:prep',
  'artifacts:snapshot:deb',
  'artifacts:snapshot:rpm',
  :spec_prep
]

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
    dls = Nokogiri::HTML(open('https://www.elastic.co/downloads/elasticsearch'))
    dls
      .at_css('#preview-release-id')
      .at_css('.downloads')
      .xpath('li/a[contains(text(), "rpm") or contains(text(), "deb")]')
      .each do |anchor|
        filename = artifact(anchor.attr('href'))
        link = artifact("elasticsearch-snapshot.#{anchor.text.split(' ').first.downcase}")
        checksum = filename + '.sha1'

        task anchor.text.split(' ').first.downcase => link
        file link => filename do
          unless File.exist?(link) and File.symlink?(link) \
              and File.readlink(link) == filename
            File.delete link if File.exist? link
            File.symlink File.basename(filename), link
          end
        end

        file filename => checksum do
          get anchor.attr('href'), filename
        end

        task checksum do
          File.delete checksum if File.exist? checksum
          get "#{anchor.attr('href')}.sha1", checksum
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
