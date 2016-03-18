require 'rubygems'
require 'puppetlabs_spec_helper/rake_tasks'
require 'net/http'
require 'uri'
require 'fileutils'

exclude_paths = [
  "pkg/**/*",
  "vendor/**/*",
  "spec/**/*",
]

pe_version = ENV['BEAKER_PE_VER']
pe_version ||= '3.8.0'
pe_baseurl = "https://s3.amazonaws.com/pe-builds/released/#{pe_version}"

require 'puppet-doc-lint/rake_task'
PuppetDocLint.configuration.ignore_paths = exclude_paths

require 'puppet-lint/tasks/puppet-lint'
require 'puppet-syntax/tasks/puppet-syntax'

PuppetSyntax.exclude_paths = exclude_paths
PuppetSyntax.future_parser = true if ENV['FUTURE_PARSER'] == 'true'

[
  '80chars',
  'class_inherits_from_params_class',
  'class_parameter_defaults',
  'documentation',
  'single_quote_string_with_variables'
].each do |check|
  PuppetLint.configuration.send("disable_#{check}")
end

PuppetLint.configuration.ignore_paths = exclude_paths
PuppetLint.configuration.log_format = "%{path}:%{linenumber}:%{check}:%{KIND}:%{message}"


artifacts = {
  'https://github.com/lmenezes/elasticsearch-kopf/archive/v2.1.1.zip' => 'elasticsearch-kopf.zip',
  'https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-1.3.1.deb' => 'elasticsearch-1.3.1.deb',
  'https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-1.1.0.deb' => 'elasticsearch-1.1.0.deb',
  'https://download.elastic.co/elasticsearch/elasticsearch/elasticsearch-1.3.1.noarch.rpm' => 'elasticsearch-1.3.1.noarch.rpm',
  'https://github.com/lukas-vlcek/bigdesk/zipball/v2.4.0' => 'elasticsearch-bigdesk.zip',
}

{
    :el => {
        :arch     => "x86_64",
        :versions => [6, 7],
    },
    :sles => {
        :arch     => "x86_64",
        :versions => [11, 12],
    },
    :ubuntu => {
        :arch     => "amd64",
        :versions => ["12.04", "14.04"],
    },
    :debian => {
        :arch     => "amd64",
        :versions => [7],
    },
}.each do |distro, metadata|
    metadata[:versions].each do |version|
        file = "puppet-enterprise-#{pe_version}-#{distro}-#{version}-#{metadata[:arch]}.tar.gz"
        artifacts[[pe_baseurl, file].join('/')] = file
    end
end

artifacts.each { |_, fn| fn.replace "spec/fixtures/artifacts/#{fn}" }

namespace :artifacts do
  desc "Fetch artifacts for tests"
  task :prep do
    artifacts.each do |url, fp|
      next if File.exists? fp
      puts "Fetching #{url}..."
      found = false
      until found
        uri = URI::parse(url)
        conn = Net::HTTP.new(uri.host, uri.port)
        conn.use_ssl = true
        res = conn.get(uri.path)
        if res.header['location']
          url = res.header['location']
        else
          found = true
        end
      end
      File.open(fp, 'w+') { |fh| fh.write res.body }
    end
  end

  desc "Purge fetched artifacts"
  task :clean do
    FileUtils.rm_rf(Dir.glob('spec/fixtures/artifacts/*'))
  end
end
