# frozen_string_literal: true
require "data"
require "active_support/inflector"
module Agilizer
  module Data

    # Repository interface for access to storage of Issue records.
    class IssueRepository

      JSON_COLUMNS = %w(
        final_fix_version
        fix_versions
        github_pull_requests
        history
        sprints
        statuses_statistics
        time_per_status
        worklogs
      ).freeze

      ARRAY_COLUMNS = {
        "changed_files" => :varchar,
        "labels" => :varchar
      }.freeze

      def self.insert(data)
        identifier = data["identifier"]
        if find_by(identifier: identifier)
          update_where({ identifier: identifier }, data)
        else
          table.insert row(data)
        end
      end

      def self.delete_where(where_params)
        table.where(where_params).delete
      end

      def self.update_where(where_params, data)
        table.where(where_params).update(row(data))
      end

      def self.first_where(where_params)
        table.where(where_params).first
      end

      # @return [Hash] the data corresponding to the found record, with
      #   String keys.
      def self.find_by(identifier:)
        record_data = table.where(identifier: identifier).first
        stringify_keys(record_data)
      end

      def self.index
        table.entries
      end

      def self.count
        table.count
      end

      def self.last
        table.order(:created_at).last
      end

      def self.table
        DB[:issues]
      end

      def self.row(data, time = nil)
        JSON_COLUMNS.each do |json_column|
          data[json_column] = Sequel.pg_json(data[json_column]) unless data[json_column].nil?
        end
        ARRAY_COLUMNS.each do |array_column, array_type|
          data[array_column] = Sequel.pg_array(data[array_column], array_type) unless data[array_column].nil?
        end

        time ||= Time.now
        data.merge(
          "local_created_at" => time,
          "local_updated_at" => time
        )
      end

      def self.stringify_keys(data)
        return nil if data.nil?
        data.each_with_object({}) do |(k, v), hash|
          hash[k.to_s] = v
        end
      end
    end
  end
end
