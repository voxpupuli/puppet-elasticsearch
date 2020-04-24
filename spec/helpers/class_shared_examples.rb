shared_examples 'class' do |init|
  it { should compile.with_all_deps }
  # it { should contain_augeas('defaults') }
  it { should contain_datacat('/etc/elasticsearch/elasticsearch.yml') }
  it { should contain_datacat_fragment('main_config') }
  it { should contain_service('elasticsearch') }

  %w[elasticsearch.yml log4j2.properties].each do |file|
    it { should contain_file("/etc/elasticsearch/#{file}") }
  end

  case init
  when :sysv
    # it { should contain_elasticsearch__service__init(name) }
    # it { should contain_elasticsearch_service_file("/etc/init.d/elasticsearch-#{name}") }
    # it { should contain_file('/etc/init.d/elasticsearch') }
  when :systemd
    # it { should contain_elasticsearch__service__systemd(name) }
    # it { should contain_file('/lib/systemd/system/elasticsearch.service') }
    # it { should contain_exec('systemd_reload') }
  end
end
