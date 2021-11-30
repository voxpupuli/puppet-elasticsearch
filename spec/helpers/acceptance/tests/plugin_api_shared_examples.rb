# frozen_string_literal: true

require 'json'

shared_examples 'plugin API response' do |es_config, desc, val|
  describe port(es_config['http.port']) do
    it 'open', :with_retries do
      expect(subject).to be_listening
    end
  end

  describe "http://localhost:#{es_config['http.port']}/_cluster/stats" do
    subject { shell("curl http://localhost:#{es_config['http.port']}/_cluster/stats") }

    it desc, :with_retries do
      expect(
        JSON.parse(subject.stdout)['nodes']['plugins']
      ).to include(include(val))
    end
  end
end
