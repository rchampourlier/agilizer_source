require 'hash_op/math'

module Agilizer
  module Interface
    module Jira
      module Transformations

        # Transformation to add the timespent per team member per status
        #
        # Required transformation on processed data:
        #   - AddStatusToWorklogs
        #
        module AddTimespentPerStatusPerAuthor

          def run(_source_data, processing_data)
            worklogs = processing_data['worklogs']
            timespent_per_status_per_author = worklogs_timespent_per_status_per_author(worklogs)
            processing_data.merge 'timespent_per_status_per_author' => timespent_per_status_per_author
          end
          module_function :run

          # IMPLEMENTATION FUNCTIONS

          # @param worklogs [Array] of worklogs from the issue
          # @return [Hash]
          #   - key: the team member name
          #   - value: Hash
          #     - key: the status
          #     - value: the timespent
          def worklogs_timespent_per_status_per_author(worklogs)
            return nil if worklogs.empty?
            worklogs_grouped_by_author_by_status = HashOp::Grouping.group_on_paths(worklogs, %w(author status))
            worklogs_grouped_by_author_by_status.map do |author, worklogs_by_status|
              timespent_per_status = worklogs_by_status.map do |_status, worklogs|
                HashOp::Math.sum_on_groups(worklogs, 'status', 'timespent')
              end.flatten
              { 'author' => author, 'timespent' => timespent_per_status }
            end
          end
          module_function :worklogs_timespent_per_status_per_author
        end
      end
    end
  end
end
