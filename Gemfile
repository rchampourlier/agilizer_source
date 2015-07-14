source 'https://rubygems.org'

ruby '2.2.1'

# Base
gem 'pry' # used on production console too
gem 'rake'
gem 'activesupport'
gem 'mongoid'
gem 'puma'

# Processing
gem 'thread'
gem 'hash_op',
  git: 'https://github.com/rchampourlier/hash_op',
  ref: :master

# Interfaces
gem 'jira_cache',
  git: 'https://github.com/rchampourlier/jira_cache',
  ref: :master

group :development do
  gem 'dotenv'
  gem 'pry-byebug'
  gem 'pry-stack_explorer'
  gem 'guard'
  gem 'guard-rspec', require: false
  gem 'guard-shotgun'
  gem 'terminal-notifier-guard'
  gem 'awesome_print'
end

group :test do
  gem 'rspec'
  gem 'rack-test'
  gem 'coveralls', require: false
  gem 'simplecov', require: false
  gem 'simplecov-json', require: false
end
