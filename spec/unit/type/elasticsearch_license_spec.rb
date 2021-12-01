# frozen_string_literal: true

require_relative '../../helpers/unit/type/elasticsearch_rest_shared_examples'

describe Puppet::Type.type(:elasticsearch_license) do
  let(:resource_name) { 'license' }

  include_examples 'REST API types', 'license', :content

  describe 'license' do
    let(:resource) do
      described_class.new(
        name: resource_name,
        ensure: 'present',
        content: {
          'license' => {
            'uid' => 'cbff45e7-c553-41f7-ae4f-9205eabd80xx',
            'type' => 'trial',
            'issue_date_in_millis' => '1519341125550',
            'expiry_date_in_millis' => '1521933125550',
            'max_nodes' => '1000',
            'issued_to' => 'test',
            'issuer' => 'elasticsearch',
            'signature' => 'secretvalue',
            'start_date_in_millis' => '1513814400000'
          }
        }
      )
    end

    let(:content) { resource.property(:content) }

    describe 'insync?' do
      let(:is_content) do
        {
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
      end

      describe 'synced properties' do
        it 'only enforces defined content' do
          expect(content).to be_insync(is_content)
        end
      end

      describe 'out-of-sync property' do
        {
          'uid' => 'cbff45e7-c553-41f7-ae4f-xxxxxxxxxxxx',
          'issue_date_in_millis' => '1513814400000',
          'expiry_date_in_millis' => '1533167999999',
          'start_date_in_millis' => '-1'
        }.each_pair do |field, value|
          let(:changed_content) do
            is_content['license'][field] = value
            is_content
          end

          it "detection for #{field}" do
            expect(content).not_to be_insync(changed_content)
          end
        end
      end
    end
  end
end
