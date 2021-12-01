require 'json'

shared_examples 'plugin API response' do |es_config, desc, val|
  describe port(es_config['http.port']) do
    it 'open', :with_retries do
      should be_listening
    end
  end

  describe server :container do
    describe http(
      "http://localhost:#{es_config['http.port']}/_cluster/stats"
    ) do
      it desc, :with_retries do
        expect(
          JSON.parse(response.body)['nodes']['plugins']
        ).to include(include(val))
      end
    end
  end
end
