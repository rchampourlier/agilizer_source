# frozen_string_literal: true
require "jira_cache"
require "agilizer/interface/jira/notifier"

module Agilizer
  module Interface

    # Importer for JIRA.
    #
    # To perform a JIRA project issue full sync:
    #     Agilizer::Interface::JIRA.import(project_key, client_options)
    #
    # To transform JIRA data for a single issue:
    #     Agilizer::Interface::JIRA::Transformations.run(data)
    class JIRA
      attr_reader :jira_config, :logger

      # @param domain [String] JIRA domain
      # @param username [String] JIRA username
      # @param password [String] JIRA password
      # @param logger [Logger]
      def initialize(jira_config: default_jira_config, logger: default_logger)
        @jira_config = jira_config
        @logger = logger
      end

      # Performs a sync through `JiraCache.sync_project_issues` format
      # the specified project.
      # JiraCache notifies each issue fetch through the provided
      # notifier, which handles processing the fetched issue
      # to create or update an Agilizer issue.
      #
      # @param project_key [String]
      # @param :jira_config [Hash] -- mandatory
      #   - domain [String] JIRA API domain
      #   - username [String] JIRA username
      #   - password [String] JIRA password
      # @param :logger [Logger] the logger used by the JIRA client to log
      #     operations
      def import_project(project_key)
        JiraCache.sync_project_issues(client, project_key)
      end

      def import_issue(issue_key)
        JiraCache.sync_issue(client, issue_key)
      end

      # Returns a Sinatra::App instance for responding to JIRA webhooks.
      # Responds to POST /jira/
      #
      # To run the app processing JIRA webhooks, set it up in your
      # `config.ru` like this:
      #
      #     map "jira" do
      #       run Agilizer::Interface::JIRA.webhook_app(client_options)
      #     end
      def webhook_app
        JiraCache.webhook_app(client)
      end

      private

      def default_jira_config
        {
          domain: ENV["JIRA_DOMAIN"],
          username: ENV["JIRA_USERNAME"],
          password: ENV["JIRA_PASSWORD"]
        }
      end

      def default_logger
        Logger.new(STDOUT)
      end

      def client
        client_config = jira_config.merge(
          notifier: notifier,
          logger: logger
        )
        JiraCache::Client.new(client_config)
      end

      def notifier
        Notifier.new
      end
    end
  end
end
