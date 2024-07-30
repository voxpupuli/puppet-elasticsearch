# frozen_string_literal: true

require_relative '../../../helpers/unit/provider/elasticsearch_rest_shared_examples'

describe Puppet::Type.type(:elasticsearch_license).provider(:ruby) do # rubocop:disable RSpec/MultipleMemoizedHelpers
  let(:example1) do
    {
      name: 'license',
      ensure: :present,
      provider: :ruby,
      content: {
        'licenses' => [ {
          #'status' => 'active',
          #'uid' => 'cbff45e7-c553-41f7-ae4f-9205eabd80xx',
          #'type' => 'trial',
          #'issue_date' => '2018-02-22T23:12:05.550Z',
          #'issue_date_in_millis' => 1_519_341_125_550,
          #'expiry_date' => '2018-03-24T23:12:05.550Z',
          #'expiry_date_in_millis' => 1_521_933_125_550,
          #'max_nodes' => 1_000,
          #'issued_to' => 'test',
          #'issuer' => 'elasticsearch',
          #'start_date_in_millis' => 1_513_814_400_000
          'uid' => '893361dc-9749-4997-93cb-802e3d7fa4xx',
          'type' => 'trial',
          'issue_date_in_millis' => 1_411_948_800_000,
          'expiry_date_in_millis' => 1_914_278_399_999,
          'max_nodes' => 1,
          'issued_to' => 'test',
          'issuer' => 'elasticsearch'
        } ]
      }
    }
  end

  let(:json1) do
    {
      # 'license' => {
      #   'status' => 'active',
      #   'uid' => 'cbff45e7-c553-41f7-ae4f-9205eabd80xx',
      #   'type' => 'trial',
      #   'issue_date' => '2018-02-22T23:12:05.550Z',
      #   'issue_date_in_millis' => '1519341125550',
      #   'expiry_date' => '2018-03-24T23:12:05.550Z',
      #   'expiry_date_in_millis' => '1521933125550',
      #   'max_nodes' => '1000',
      #   'issued_to' => 'test',
      #   'issuer' => 'elasticsearch',
      #   'start_date_in_millis' => '1513814400000'
      # }
      'licenses' => [ {
          "uid" => '893361dc-9749-4997-93cb-802e3d7fa4xx',
          "type" => 'trial',
          "issue_date_in_millis" => '1411948800000',
          "expiry_date_in_millis" => '1914278399999',
          "max_nodes" => '1',
          "issued_to" => 'test',
          "issuer" => 'elasticsearch',
        } ]
    }
  end

  let(:resource) { Puppet::Type::Elasticsearch_index.new props }
  let(:provider) { described_class.new resource }
  let(:props) do
    {
      name: name,
      settings: {
        'index' => {
          'number_of_replicas' => 0
        }
      }
    }
  end

  include_examples 'REST API', '_license'
end
