require 'mongoid'

env = ENV['AGILIZER_ENV']
fail 'AGILIZER_ENV environment variable must be set' if env.nil?

ENV['MONGOID_ENV'] = env
Mongoid.load! File.expand_path('../mongoid.yml', __FILE__)
