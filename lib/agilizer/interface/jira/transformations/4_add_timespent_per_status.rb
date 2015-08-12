require 'hash_op/math'

module Agilizer
  module Interface
    module Jira
      module Transformations

        # Transformation to add the timespent per status to the issue
        # data.
        module AddTimespentPerStatus

          def run(_source_data, processing_data)
            worklogs = processing_data['worklogs']
            timespent_per_status = worklogs_timespent_per_status(worklogs)
            processing_data.merge 'timespent_per_status' => timespent_per_status
          end
          module_function :run

          # IMPLEMENTATION FUNCTIONS

          # TODO update doc
          #
          # @param essence [Hash] the essence must:
          #   - include worklogs (Process::map)
          #
          # @return [Hash]
          #   - key: the status
          #   - value: the timespent during the status
          #
          def worklogs_timespent_per_status(worklogs)
            return nil if worklogs.empty?
            HashOp::Math.sum_on_groups(worklogs, 'status', 'timespent')
          end
          module_function :worklogs_timespent_per_status
        end
      end
    end
  end
end
