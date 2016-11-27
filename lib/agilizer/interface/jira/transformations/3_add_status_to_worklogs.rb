require 'agilizer/interface/jira/transformations/support/value_at_time'

module Agilizer
  module Interface
    class JIRA
      module Transformations

        # For each worklog in the processing data, add 'status' corresponding
        # to the status of the issue at the time of the worklog.
        #
        # NB:
        #   - if the processing data doesn't contain worklogs,
        #     it is returned unchanged,
        #   - if the processing data doesn't contain history (added by
        #     the `AddSimpleHistory` transformation), an error is raised.
        module AddStatusToWorklogs

          def run(_source_data, processing_data)
            worklogs = processing_data['worklogs']
            return processing_data if worklogs.nil? || worklogs.empty?

            enriched_worklogs = worklogs.map do |worklog|
              time = worklog['time']
              status = Support.value_at_time(processing_data, 'status', time)
              worklog.merge 'status' => status
            end

            processing_data.merge 'worklogs' => enriched_worklogs
          end
          module_function :run
        end
      end
    end
  end
end
