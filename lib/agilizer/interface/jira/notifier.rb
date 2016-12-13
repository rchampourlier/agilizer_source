# frozen_string_literal: true
require "logger"
require "event_bus"
require "agilizer/interface/jira/transformations"
require "agilizer/data/issue_repository"

module Agilizer
  module Interface
    class JIRA

      # An instance of the notifier is associated to the `JiraCache::Client`
      # instance and #publish is called when specific events of the client
      # happen, such as:
      #   - fetched_issue
      class Notifier
        attr_reader :logger

        def initialize(logger: nil)
          @logger = logger
          EventBus.subscribe do |event_name:, event_data:|
            logger.debug("Received event named \"#{event_name}\"") if logger
            case event_name
            when :fetched_issue then process_fetched_issue(event_data: event_data)
            else raise StandardError, "Unknown event \"#{event_name}\""
            end
          end
        end

        def publish(event_name, event_data)
          EventBus.publish(event_name: event_name.to_sym, event_data: event_data)
        end

        private

        def process_fetched_issue(event_data:)
          issue_key = event_data[:key]
          issue_data = event_data[:data]
          transformed_data = Transformations.run(issue_data)
          Data::IssueRepository.insert(transformed_data)
          logger.info "Updated issue #{issue_key}" if logger
        end
      end
    end
  end
end
