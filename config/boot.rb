# Load dependencies
require 'rubygems'
require 'bundler/setup'

ENV['APP_ENV'] = 'development' if ENV['APP_ENV'].nil?
env = ENV['APP_ENV']
if env == 'development' || env == 'test'
  require 'dotenv'
  Dotenv.load
end

root_dir = File.expand_path '../..', __FILE__

$LOAD_PATH.unshift root_dir
$LOAD_PATH.unshift File.join(root_dir, 'lib')
$LOAD_PATH.unshift File.join(root_dir, 'lib', 'agilizer')
require 'config/mongo'
