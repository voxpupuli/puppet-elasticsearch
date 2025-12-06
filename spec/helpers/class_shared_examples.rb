# frozen_string_literal: true

shared_examples 'class' do
  it { is_expected.to compile.with_all_deps }

  it do
    if facts[:os]['family'] == 'Debian'
      is_expected.to contain_augeas('/etc/default/elasticsearch')
    else
      is_expected.to contain_augeas('/etc/sysconfig/elasticsearch')
    end
  end

  it { is_expected.to contain_file('/etc/elasticsearch/elasticsearch.yml') }
  it { is_expected.to contain_service('elasticsearch') }
end
