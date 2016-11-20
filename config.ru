ENV['RACK_ENV'] ||= ENV['APP_ENV'] ||= 'development'

root_dir = File.dirname(__FILE__)
require File.join(root_dir, 'config', 'boot')

require "logger"
logger = Logger.new(STDOUT)
logger.level = Logger.const_get(ENV['JIRA_LOG_LEVEL'].to_sym)

# JIRA webhook for synchronization
# (optional: bin/sync script may be used instead)
map '/jira' do
  require 'agilizer/interface/jira'
  run Agilizer::Interface::Jira.webhook_app(
    domain: ENV['JIRA_DOMAIN'],
    username: ENV['JIRA_USERNAME'],
    password: ENV['JIRA_PASSWORD'],
    logger: logger
  )
end
