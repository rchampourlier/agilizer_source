ENV['RACK_ENV'] ||= ENV['APP_ENV'] ||= 'development'

root_dir = File.dirname(__FILE__)
require File.join(root_dir, 'config', 'boot')

logger = Logger.new(STDOUT)
logger.level = Logger.const_get(ENV['AGILIZER_JIRA_LOG_LEVEL'].to_sym)

map '/api' do

  # Setup CORS
  require 'rack/cors'
  use Rack::Cors do
    allow do
      origins /localhost:\d+/
      resource '*', headers: :any, methods: [:get, :post, :options]
    end
  end

  # Setup Rabl
  use Rack::Config do |env|
    env['api.tilt.root'] = File.join(root_dir, '/lib/agilizer/api/resources')
  end

  # Mount the API
  require 'agilizer/api/app'
  run Agilizer::API::App
end

map '/jira' do
  require 'agilizer/interface/jira'
  run Agilizer::Interface::Jira.webhook_app(
    domain: ENV['AGILIZER_JIRA_DOMAIN'],
    username: ENV['AGILIZER_JIRA_USERNAME'],
    password: ENV['AGILIZER_JIRA_PASSWORD'],
    logger: logger
  )
end
