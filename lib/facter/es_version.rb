
Facter.add("es_version") do
  setcode do
    Facter::Util::Resolution.exec("wget -o /dev/null -O - http://www.elasticsearch.org/download/ | sed -n 's/.*<span class=\"version\">\\([0-9\\.]*\\)<\\/span.*/\\1/p'")
  end
end
