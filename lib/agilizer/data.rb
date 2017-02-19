# frozen_string_literal: true
require "sequel"

module Agilizer
  module Data
    DATABASE_URL = ENV["DATABASE_URL"]
    Sequel.extension :pg_json_ops
    DB = Sequel.connect(DATABASE_URL)
    DB.extension :pg_array, :pg_json
  end
end
