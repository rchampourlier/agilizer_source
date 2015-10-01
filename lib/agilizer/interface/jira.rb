require 'jira_cache'
require 'agilizer/interface/jira/notifier'

module Agilizer
  module Interface

    # Importer for JIRA.
    #
    # To perform a JIRA project issue full sync:
    #     Agilizer::Interface::Jira.import(project_key, client_options)
    #
    # To transform JIRA data for a single issue:
    #     Agilizer::Interface::Jira::Transformation.run(data)
    module Jira

      # Performs a sync through `JiraCache.sync_project_issues` format
      # the specified project.
      # JiraCache notifies each issue fetch through the provided
      # notifier, which handles processing the fetched issue
      # to create or update an Agilizer issue.
      #
      # @param project_key [String]
      # @param client_options [Hash]
      #   - domain [String] JIRA API domain
      #   - username [String] JIRA username
      #   - password [String] JIRA password
      #   - logger [Logger] the logger used by the JIRA client to log
      #     operations
      def import_project(project_key, client_options)
        JiraCache.sync_project_issues(client(client_options), project_key)
      end
      module_function :import_project

      def import_issue(issue_key, client_options)
        JiraCache.sync_issue(client(client_options), issue_key)
      end
      module_function :import_issue

      # @param client_options [Hash] same as `::import`
      #
      # To run the app processing JIRA webhooks, set it up in your
      # `config.ru` like this:
      #
      #     map 'jira' do
      #       run Agilizer::Interface::Jira.webhook_app(client_options)
      #     end
      def webhook_app(client_options)
        JiraCache.webhook_app(client(client_options))
      end
      module_function :webhook_app

      # IMPLEMENTATION METHODS

      def client(options)
        logger = options[:logger]
        notifier = notifier(logger: logger)
        JiraCache::Client.new(options.merge(notifier: notifier))
      end
      module_function :client

      def notifier(logger: nil)
        Notifier.new(logger: logger)
      end
      module_function :notifier
    end
  end
end
