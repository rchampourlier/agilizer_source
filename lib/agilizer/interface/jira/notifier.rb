require 'agilizer/interface/jira/transformation'
require 'agilizer/update_manager'

module Agilizer
  module Interface
    module Jira

      # An instance of the notifier is associated to the `JiraCache::Client`
      # instance and #publish is called when specific events of the client
      # happen, such as:
      #   - fetched_issue
      class Notifier

        def initialize(logger: nil)
          @logger = logger
        end

        def publish(event_name, event_data)
          send(:"on_#{event_name}", event_data)
        end

        private

        def on_fetched_issue(event_data)
          issue_key = event_data[:key]
          issue_data = event_data[:data]
          transformed_data = Transformation.run(issue_data)
          begin
            UpdateManager.run(transformed_data)
            logger.info "Updated issue #{issue_key}"
          rescue => e
            issue_key = event_data[:key]
            logger.fatal "Failed to write transformed data for #{issue_key} (#{e})"
          end
        end

        def logger
          @logger ||= (
            logger = Logger.new(STDOUT)
            logger.level = Logger::DEBUG
            logger
          )
        end
      end
    end
  end
end
