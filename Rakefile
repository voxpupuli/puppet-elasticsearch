# rubocop:disable Style/FileName
require 'rubygems'
require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet_blacksmith/rake_tasks'
require 'net/http'
require 'uri'
require 'fileutils'
require 'rspec/core/rake_task'
require 'puppet-doc-lint/rake_task'
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
  documentation
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

desc 'Run documentation tests'
task :spec_docs do
  results = PuppetDocLint::Runner.new.run(
    FileList['**/*.pp'].exclude(*exclude_paths)
  )

  results.each(&:result_report)
  abort 'Issues found' if results.map(&:percent_documented).any? { |n| n < 100 }
end

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

desc 'Run integration tests'
RSpec::Core::RakeTask.new('beaker:integration') do |c|
  c.pattern = 'spec/integration/integration*.rb'
end
task 'beaker:integration' => [:spec_prep, 'artifacts:prep']

desc 'Run acceptance tests'
RSpec::Core::RakeTask.new('beaker:acceptance') do |c|
  c.pattern = 'spec/acceptance/0*_spec.rb'
end
task 'beaker:acceptance' => [:spec_prep, 'artifacts:prep']

if !ENV['BEAKER_IS_PE'].nil? and ENV['BEAKER_IS_PE'] == 'true'
  task :beaker => 'artifacts:pe'
  task 'beaker:integration' => 'artifacts:pe'
  task 'beaker:acceptance' => 'artifacts:pe'
end

# rubocop:disable Metrics/BlockLength
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

  desc 'Retrieve PE archives'
  task :pe do
    if !ENV['BEAKER_set'].nil?
      case ENV['BEAKER_set']
      when /centos-(?<release>\d)/
        distro = 'el'
        version = Regexp.last_match(:release)
        arch = 'x86_64'
      when /(?<distro>debian)-(?<release>\d)/
        distro = Regexp.last_match(:distro)
        version = Regexp.last_match(:release)
        arch = 'amd64'
      when /(?<distro>sles)-(?<release>\d+)/
        distro = Regexp.last_match(:distro)
        version = Regexp.last_match(:release)
        arch = 'x86_64'
      when /(?<distro>ubuntu)-server-(?<release>12|14)/
        distro = Regexp.last_match(:distro)
        version = "#{Regexp.last_match(:release)}.04"
        arch = 'amd64'
      else
        puts "Could not find PE version for #{ENV['BEAKER_set']}"
        return
      end
      pe_ver = ENV['BEAKER_PE_VER']
      file = "puppet-enterprise-#{pe_ver}-#{distro}-#{version}-#{arch}.tar.gz"
      fetch_archives(
        "https://s3.amazonaws.com/pe-builds/released/#{pe_ver}/#{file}" => file
      )
    else
      puts 'No nodeset set, skipping PE artifact retrieval'
    end
  end

  desc 'Purge fetched artifacts'
  task :clean do
    FileUtils.rm_rf(Dir.glob('spec/fixtures/artifacts/*'))
  end
end

def fetch_archives(archives)
  archives.each do |url, fp|
    fp.replace "spec/fixtures/artifacts/#{fp}"
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
