# Load dependencies
require 'rubygems'
require 'bundler/setup'

ENV['AGILIZER_ENV'] = 'test'

if ENV['CI']
  # Running on CI, setup Coveralls
  require 'coveralls'
  Coveralls.wear!
else
  # Running locally, setup simplecov
  require 'simplecov'
  require 'simplecov-json'
  SimpleCov.start do
    add_filter do |src|
      # Ignoring files from the spec directory
      src.filename =~ %r{/spec/}
    end
  end
  SimpleCov.formatter = SimpleCov::Formatter::JSONFormatter
end

$LOAD_PATH.unshift File.expand_path('../..', __FILE__) # root
$LOAD_PATH.unshift File.expand_path('../../spec', __FILE__)
require 'config/boot'

require 'spec/support/spec_case'

# Cleaning database after each test
require 'agilizer/issue'
require 'jira_cache/issue'
require 'jira_cache/project_state'
RSpec.configure do |config|
  config.after(:each) do
    JiraCache::Issue.destroy_all
    JiraCache::ProjectState.destroy_all
    Agilizer::Issue.destroy_all
  end
end
