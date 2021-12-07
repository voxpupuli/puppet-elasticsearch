# frozen_string_literal: true

require 'json'
require 'spec_helper_rspec'
require 'webmock/rspec'

shared_examples 'REST API' do |resource_type, create_uri, singleton = false|
  unless singleton
    describe 'instances' do
      context "with no #{resource_type}s" do
        it 'returns an empty list' do
          stub_request(:get, "http://localhost:9200/_#{resource_type}").
            with(headers: { 'Accept' => 'application/json' }).
            to_return(
              status: 200,
              body: '{}'
            )

          expect(described_class.instances).to eq([])
        end
      end
    end
  end

  describe "#{resource_type}s" do
    if singleton
      let(:json) { json1 }
      let(:instance) { [example1] }
    else
      let(:json) { json1.merge(json2) }
      let(:instance) { [example1, example2] }
    end

    it "returns #{resource_type}s" do
      stub_request(:get, "http://localhost:9200/_#{resource_type}").
        with(headers: { 'Accept' => 'application/json' }).
        to_return(
          status: 200,
          body: JSON.dump(json)
        )

      expect(described_class.instances.map do |provider|
        provider.instance_variable_get(:@property_hash)
      end).to contain_exactly(*instance)
    end
  end

  describe 'basic authentication' do
    it 'authenticates' do
      stub_request(:get, "http://localhost:9200/_#{resource_type}").
        with(
          basic_auth: %w[elastic password],
          headers: { 'Accept' => 'application/json' }
        ).
        to_return(
          status: 200,
          body: JSON.dump(json1)
        )

      expect(described_class.api_objects(
        'http', 'localhost', '9200', 10, 'elastic', 'password', validate_tls: true
      ).map do |provider|
        described_class.new(
          provider
        ).instance_variable_get(:@property_hash)
      end).to contain_exactly(example1)
    end
  end

  describe 'https' do
    it 'uses ssl' do
      stub_request(:get, "https://localhost:9200/_#{resource_type}").
        with(headers: { 'Accept' => 'application/json' }).
        to_return(
          status: 200,
          body: JSON.dump(json1)
        )

      expect(described_class.api_objects(
        'https', 'localhost', '9200', 10, validate_tls: true
      ).map do |provider|
        described_class.new(
          provider
        ).instance_variable_get(:@property_hash)
      end).to contain_exactly(example1)
    end
  end

  unless singleton
    describe 'flush' do
      it "creates #{resource_type}s" do
        stub_request(:put, "http://localhost:9200/#{create_uri}").
          with(
            headers: {
              'Accept' => 'application/json',
              'Content-Type' => 'application/json'
            },
            body: bare_resource
          )
        stub_request(:get, "http://localhost:9200/_#{resource_type}").
          with(headers: { 'Accept' => 'application/json' }).
          to_return(status: 200, body: '{}')

        provider.flush
      end
    end
  end
end
