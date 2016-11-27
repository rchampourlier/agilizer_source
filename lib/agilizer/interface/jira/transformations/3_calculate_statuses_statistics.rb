require "agilizer/interface/jira/transformations/support/value_at_time"

module Agilizer
  module Interface
    class JIRA
      module Transformations

        # Calculates statistics on the issue status changes:
        #   - `development_started_at`: time of the first status change
        #     corresponding to start of development (change to
        #     "In Progress" or "In Development")
        #   - `review_started_at`: time of the first status change
        #     corresponding to the start of the review (change to
        #     "In Review")
        #   - `functional_review_started_at`: time of the first
        #     status change corresponding to the start of the
        #     functional review (change to "In Functional Review")
        #   - `released_at`: time of release (time of the change
        #     to status "Released" or "Closed")
        #   - `closed_at`: time when the issue went to the
        #     "Closed" status
        #   - `returns_from_review`: number of times the
        #     status changed from "In Review" to a previous status
        #     ("Open", "Ready", "In Development")
        #   - `returns_from_functional_review`: number of
        #     times the status changed from "In Functional Review"
        #     to a previous status (same as above plus "In Review")
        module CalculateStatusesStatistics

          STATUSES_MOMENTS = {
            "development_started_at" => {
              statuses: ["In Progress", "In Development"],
              moment: :first
            },
            "review_started_at" => {
              statuses: ["In Review"],
              moment: :first
            },
            "functional_review_started_at" => {
              statuses: ["In Functional Review"],
              moment: :first
            },
            "released_at" => {
              statuses: ["Released"],
              moment: :last
            },
            "closed_at" => {
              statuses: ["Closed"],
              moment: :last
            }
          }

          STATUSES_RETURNS = {
            "returns_from_review" => {
              from: "In Review",
              to: ["Open", "Ready", "In Development", "In Progress"]
            },
            "returns_from_functional_review" => {
              from: "In Functional Review",
              to: ["Open", "Ready", "In Development", "In Progress", "In Review"]
            }
          }

          def run(_source_data, processing_data)
            history = processing_data["history"]
            processing_data["statuses_statistics"] = {}
            processing_data["statuses_statistics"].merge! calculate_statuses_moments(history)
            processing_data["statuses_statistics"].merge! calculate_statuses_returns(history)
            processing_data
          end
          module_function :run

          # IMPLEMENTATION

          def calculate_statuses_moments(history)
            results = empty_statuses_moments
            history.each do |item|
              next unless item["field"] == "status"
              STATUSES_MOMENTS.each do |key, config|
                next unless config[:statuses].include? item["to"]
                if results[key].nil?
                  results[key] = item["time"]
                  next
                end
                if config[:moment] == :first && results[key] > item["time"]
                  results[key] = item["time"]
                  next
                end
                if config[:moment] == :last && results[key] < item["time"]
                  results[key] = item["time"]
                  next
                end
              end
            end
            results
          end
          module_function :calculate_statuses_moments

          def empty_statuses_moments
            STATUSES_MOMENTS.keys.each_with_object({}) { |k, h| h[k] = nil }
          end
          module_function :empty_statuses_moments

          def calculate_statuses_returns(history)
            results = empty_statuses_returns
            history.each do |item|
              next unless item["field"] == "status"
              STATUSES_RETURNS.each do |key, config|
                next unless item["from"] == config[:from]
                next unless config[:to].include? item["to"]
                results[key] ||= 0
                results[key] += 1
              end
            end
            results
          end
          module_function :calculate_statuses_returns

          def empty_statuses_returns
            STATUSES_RETURNS.keys.each_with_object({}) { |k, h| h[k] = 0 }
          end
          module_function :empty_statuses_returns
        end
      end
    end
  end
end
