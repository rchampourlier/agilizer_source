# frozen_string_literal: true
require "toggl_cache"

module Agilizer
  module Interface

    # Importer for Toggl.
    #
    # To perform a Toggl workspace reports full sync:
    #     Agilizer::Interface::Toggl.import_all
    class Toggl

      # @param domain [String] JIRA domain
      # @param username [String] JIRA username
      # @param password [String] JIRA password
      # @param logger [Logger]
      def initialize(toggl_config: default_toggl_config, logger: default_logger)
        @toggl_config = toggl_config
        @logger = logger
      end

      # Performs a sync through `TogglCache.sync_issue`.
      #
      # @param date_since [Date]: date from which Toggl reports must be
      #   fetched. If not specified, `toggl_cache` gem default is used
      #   (one week).
      def import_all(date_since: nil)
        return TogglCache.sync_reports(date_since: date_since) if date_since
        TogglCache.sync_reports
      end

      private

      def default_toggl_config
        {
          workspace_id: ENV["TOGGL_WORKSPACE_ID"],
          api_token: ENV["TOGGL_API_TOKEN"]
        }
      end

      def default_logger
        Logger.new(STDOUT)
      end
    end
  end
end
