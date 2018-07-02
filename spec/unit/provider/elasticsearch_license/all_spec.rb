require_relative '../../../helpers/unit/provider/elasticsearch_rest_shared_examples'

{
  'shield' => 'license',
  'xpack' => 'xpack/license'
}.each_pair do |plugin, endpoint|
  describe Puppet::Type.type(:elasticsearch_license).provider(plugin.to_sym) do
    let(:name) { plugin }

    let(:example_1) do
      {
        :name => plugin,
        :ensure => :present,
        :provider => plugin.to_sym,
        :content => {
          'license' => {
            'status' => 'active',
            'uid' => 'cbff45e7-c553-41f7-ae4f-9205eabd80xx',
            'type' => 'trial',
            'issue_date' => '2018-02-22T23:12:05.550Z',
            'issue_date_in_millis' => 1_519_341_125_550,
            'expiry_date' => '2018-03-24T23:12:05.550Z',
            'expiry_date_in_millis' => 1_521_933_125_550,
            'max_nodes' => 1_000,
            'issued_to' => 'test',
            'issuer' => 'elasticsearch',
            'start_date_in_millis' => 1_513_814_400_000
          }
        }
      }
    end

    let(:json_1) do
      {
        'license' => {
          'status' => 'active',
          'uid' => 'cbff45e7-c553-41f7-ae4f-9205eabd80xx',
          'type' => 'trial',
          'issue_date' => '2018-02-22T23:12:05.550Z',
          'issue_date_in_millis' => '1519341125550',
          'expiry_date' => '2018-03-24T23:12:05.550Z',
          'expiry_date_in_millis' => '1521933125550',
          'max_nodes' => '1000',
          'issued_to' => 'test',
          'issuer' => 'elasticsearch',
          'start_date_in_millis' => '1513814400000'
        }
      }
    end

    let(:resource) { Puppet::Type::Elasticsearch_index.new props }
    let(:provider) { described_class.new resource }
    let(:props) do
      {
        :name => name,
        :settings => {
          'index' => {
            'number_of_replicas' => 0
          }
        }
      }
    end

    include_examples 'REST API', endpoint, nil, true
  end
end
