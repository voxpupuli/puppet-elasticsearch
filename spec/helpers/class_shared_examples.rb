# frozen_string_literal: true

shared_examples 'class' do
  it { is_expected.to compile.with_all_deps }
  it { is_expected.to contain_augeas('/etc/sysconfig/elasticsearch') }
  it { is_expected.to contain_file('/etc/elasticsearch/elasticsearch.yml') }
  it { is_expected.to contain_datacat('/etc/elasticsearch/elasticsearch.yml') }
  it { is_expected.to contain_datacat_fragment('main_config') }
  it { is_expected.to contain_service('elasticsearch') }
end
