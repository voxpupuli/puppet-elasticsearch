require 'faraday'

def middleware
  [Faraday::Request::Retry, {
    :max => 5
  }]
end
