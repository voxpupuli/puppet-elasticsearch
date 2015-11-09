# Fact: elasticsearch_version
#
# Purpose: get elasticsearch's current version
#
# Resolution:
#   Uses elasticsearch's version flag and parses the result from 'version'
#
# Caveats:
#   none
#
# Notes:
#   None
Facter.add(:elasticsearch_version) do
  setcode do
    es_exec = Facter::Core::Execution.which('elasticsearch') || '/usr/share/elasticsearch/bin/elasticsearch'
    es_ver = Facter::Core::Execution.exec("#{es_exec} -v")
    es_ver = Facter::Core::Execution.exec("#{es_exec} --version") if es_ver == ""
    es_ver.to_s.lines.first.strip.split[1].chop unless (es_ver.nil? || es_ver == "")
  end
end

