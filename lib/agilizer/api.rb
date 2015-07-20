require 'grape'
require 'grape/rabl'
require 'agilizer/issue'

module Agilizer
  class API < Grape::API
    version 'v1', using: :path, vendor: 'agilizer'
    format :json
    formatter :json, Grape::Formatter::Rabl

    %w(auth issues).each do |resource|
      require "agilizer/api/resources/#{resource}/routes"
    end
  end
end
