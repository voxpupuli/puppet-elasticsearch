require 'puppet/provider/parsedfile'

Puppet::Type.type(:elasticsearch_shield_user).provide(
  :parsed,
  :parent => Puppet::Provider::ParsedFile,
) do
  desc "Provider for Shield esusers using plain files."

  confine :exists => resource[:home_dir] + '/shield/users'

  has_feature :manages_passwords

  text_line :comment,
            :match => %r{^\s*#}

  record_line :parsed,
              :fields => %w{name hashed_password},
              :separator => ':',
              :joiner => ':'

  def self.valid_attr?(klass, attr_name)
    if klass.respond_to? :parameters
      klass.parameters.include?(attr_name)
    else
      true
    end
  end

  def default_target
    @default_target ||= resource[:home_dir] + '/shield/users'
  end
end
