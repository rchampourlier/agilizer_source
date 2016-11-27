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
        module CalculateTimePerStatus

          def run(_source_data, processing_data)
            history = processing_data['history']
            created_at = processing_data['created_at']

            processing_data['time_per_status'] = {}
            processing_data['time_per_status'].merge! calculate_time_per_status(history, created_at)

            processing_data
          end
          module_function :run

          # IMPLEMENTATION

          def calculate_time_per_status(history, created_at)
            time_per_status = Hash.new(0)
            previous_item = nil
            history.each do |item|
              next unless item['field'] == 'status'
              previous_time = previous_item.nil? ? created_at : previous_item['time']
              time_per_status[item['from']] += item['time'] - previous_time
              previous_item = item
            end
            time_per_status
          end
          module_function :calculate_time_per_status
        end
      end
    end
  end
end
