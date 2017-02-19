# frozen_string_literal: true

# Load dependencies
require "rubygems"
require "bundler/setup"
require "pry"

ENV["APP_ENV"] = "test"

# Simplecov setup
require "simplecov"
SimpleCov.start do
  add_filter do |src|
    # Ignoring files from the spec directory
    src.filename =~ %r{/spec/}
  end
end

$LOAD_PATH.unshift File.expand_path("../..", __FILE__) # root
$LOAD_PATH.unshift File.expand_path("../../spec", __FILE__)
require "config/boot"

require "spec/support/spec_case"

# Database setup, teardown and cleanup during tests
require "agilizer/data"
require "jira_cache/data/issue_repository"
require "agilizer/data/issue_repository"
client = Agilizer::Data::DB

require "sequel"
Sequel.extension :migration, :core_extensions, :pg_json_ops

MIGRATIONS_DIR = File.expand_path("../../config/db_migrations", __FILE__)
RSpec.configure do |config|
  config.order = :random

  config.before(:all) do
    Sequel::Migrator.apply(client, MIGRATIONS_DIR)
  end

  config.after(:each) do
    Agilizer::Data::IssueRepository.delete_where(true)
  end

  config.after(:all) do
    Sequel::Migrator.apply(client, MIGRATIONS_DIR, 0)
  end
end
