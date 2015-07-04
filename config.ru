ENV['RACK_ENV'] ||= ENV['APP_ENV'] ||= 'development'

root_dir = File.dirname(__FILE__)
require File.join(root_dir, 'config', 'boot')

logger = Logger.new(STDOUT)
logger.level = Logger.const_get(ENV['AGILIZER_JIRA_LOG_LEVEL'].to_sym)

map '/jira' do
  require 'agilizer/interface/jira'
  run Agilizer::Interface::Jira.webhook_app(
    domain: ENV['AGILIZER_JIRA_DOMAIN'],
    username: ENV['AGILIZER_JIRA_USERNAME'],
    password: ENV['AGILIZER_JIRA_PASSWORD'],
    logger: logger
  )
end
