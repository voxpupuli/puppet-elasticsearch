shared_examples 'class' do
  it { should compile.with_all_deps }
  it { should contain_augeas('/etc/sysconfig/elasticsearch') }
  it { should contain_file('/etc/elasticsearch/elasticsearch.yml') }
  it { should contain_datacat('/etc/elasticsearch/elasticsearch.yml') }
  it { should contain_datacat_fragment('main_config') }
  it { should contain_service('elasticsearch') }
end
