require File.join(File.dirname(__FILE__), '..', '..', '..', 'puppet/provider/elastic_user_command')

Puppet::Type.type(:elasticsearch_user).provide(
  :users,
  :parent => Puppet::Provider::ElasticUserCommand
) do
  desc 'Provider for X-Pack file (users) user resources.'

  # Prefer the newer 'elasticsearch-users' command provider
  # if the 'elasticsearch_users' command exists.
  # The logic looks a bit backwards here, but that's because
  # Puppet evals the 'confine' statement early on.
  # So we could hit false-positives due to the package
  # being installed in the same Puppet run.
  confine :true => begin
    false if File.exist?("#{homedir}/bin/elasticsearch-users")
  end

  has_feature :manages_plaintext_passwords

  mk_resource_methods

  commands :users_cli => "#{homedir}/bin/x-pack/users"
  commands :es => "#{homedir}/bin/elasticsearch"
end
