# Load dependencies
require 'rubygems'
require 'bundler/setup'

ENV['AGILIZER_ENV'] = 'development' if ENV['AGILIZER_ENV'].nil?
env = ENV['AGILIZER_ENV']
if env == 'development' || env == 'test'
  require 'dotenv'
  Dotenv.load
end

root_dir = File.expand_path '../..', __FILE__

$LOAD_PATH.unshift root_dir
$LOAD_PATH.unshift File.join(root_dir, 'lib')
$LOAD_PATH.unshift File.join(root_dir, 'lib', 'agilizer')
require 'config/mongo'
