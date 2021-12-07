# frozen_string_literal: true

require 'bcrypt'
require 'open-uri'

def to_agent_version(puppet_version)
  # REF: https://docs.puppet.com/puppet/latest/reference/about_agent.html
  {
    # Puppet => Agent
    '4.10.4' => '1.10.4',
    '4.10.3' => '1.10.3',
    '4.10.2' => '1.10.2',
    '4.10.1' => '1.10.1',
    '4.10.0' => '1.10.0',
    '4.9.4' => '1.9.3',
    '4.8.2' => '1.8.3',
    '4.7.1' => '1.7.2',
    '4.7.0' => '1.7.1',
    '4.6.2' => '1.6.2',
    '4.5.3' => '1.5.3',
    '4.4.2' => '1.4.2',
    '4.4.1' => '1.4.1',
    '4.4.0' => '1.4.0',
    '4.3.2' => '1.3.6',
    '4.3.1' => '1.3.2',
    '4.3.0' => '1.3.0',
    '4.2.3' => '1.2.7',
    '4.2.2' => '1.2.6',
    '4.2.1' => '1.2.2',
    '4.2.0' => '1.2.1',
    '4.1.0' => '1.1.1',
    '4.0.0' => '1.0.1'
  }[puppet_version]
end

def derive_artifact_urls_for(full_version, plugins = ['analysis-icu'])
  derive_full_package_url(full_version).merge(
    derive_plugin_urls_for(full_version, plugins)
  )
end

def derive_full_package_url(full_version, extensions = %w[deb rpm])
  extensions.map do |ext|
    url = if full_version.start_with? '6'
            "https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-#{full_version}.#{ext}"
          elsif ext == 'deb'
            "https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-#{full_version}-amd64.#{ext}"
          else
            "https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-#{full_version}-x86_64.#{ext}"
          end
    [url, File.basename(url)]
  end.to_h
end

def derive_plugin_urls_for(full_version, plugins = ['analysis-icu'])
  plugins.map do |plugin|
    url = "https://artifacts.elastic.co/downloads/elasticsearch-plugins/#{plugin}/#{plugin}-#{full_version}.zip"
    [url, File.join('plugins', File.basename(url))]
  end.to_h
end

def artifact(file, fixture_path = [])
  File.join(%w[spec fixtures artifacts] + fixture_path + [File.basename(file)])
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

def fetch_archives(archives)
  archives.each do |url, orig_fp|
    fp = "spec/fixtures/artifacts/#{orig_fp}"
    if File.exist? fp
      if fp.end_with?('tar.gz') && !system("tar -tzf #{fp} &>/dev/null")
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

def pid_file
  if fact('operatingsystem') == 'Debian' \
      && fact('lsbmajdistrelease').to_i <= 7
    '/var/run/elasticsearch.pid'
  else
    '/var/run/elasticsearch/elasticsearch.pid'
  end
end

def vault_available?
  if ENV['CI']
    %w[VAULT_ADDR VAULT_APPROLE_ROLE_ID VAULT_APPROLE_SECRET_ID VAULT_PATH].select do |var|
      ENV[var].nil?
    end.empty?
  else
    true
  end
end

def http_retry(url)
  retries ||= 0
  URI.parse(url).open.read
rescue StandardError
  retry if (retries += 1) < 3
end

# Helper to store arbitrary testing setting values
def v
  RSpec.configuration.v
end

def semver(version)
  Gem::Version.new version
end

def bcrypt(value)
  BCrypt::Password.create(value)
end
