require 'rack/test'

module APIHelper
  include Rack::Test::Methods

  def app
    Agilizer::App::API
  end

  def response_status
    last_response.status
  end

  def parsed_response
    JSON.parse(last_response.body)
  end
end
