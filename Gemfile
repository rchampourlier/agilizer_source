# frozen_string_literal: true
source "https://rubygems.org"

ruby "2.3.3"

# Base
gem "rake"
gem "puma"

# Storage
gem "pg"
gem "sequel"
gem "sequel_pg"

# Processing
gem "thread"
gem "hash_op",
  git: "https://github.com/rchampourlier/hash_op",
  ref: "master"

# Interfaces
gem "jira_cache", "~> 0.2.2"
gem "toggl_cache", "~> 0.2.1"

# Enrichments
gem "rest-client"

# API
gem "rack-cors"
gem "grape"
gem "grape-rabl"

# Patterns
gem "event_train", "~> 0.2.1"

# Client-side
gem "sinatra"

# Required in production group too
gem "pry" # for console
gem "rspec" # for Rakefile

group :development do
  gem "dotenv"
  gem "pry-remote"
  # gem "pry-byebug"
  # gem "pry-stack_explorer"
  gem "guard"
  gem "guard-rspec", require: false
  gem "guard-shotgun"
  gem "terminal-notifier-guard"
  gem "awesome_print"
  gem "faker" # for build_spec_case_post_process
end

group :test do
  gem "rack-test"
  gem "simplecov", require: false
  gem "timecop", require: false
  gem "codeclimate-test-reporter", "~> 1.0.0"
end
