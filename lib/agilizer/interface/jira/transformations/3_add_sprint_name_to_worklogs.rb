require 'agilizer/interface/jira/transformations/support/value_at_time'

module Agilizer
  module Interface
    module Jira
      module Transformations

        # For each worklog of the processing data, add 'sprint_name' corresponding
        # to the sprint_name of the issue at the time of the worklog.
        module AddSprintNameToWorklogs

          def run(_source_data, processing_data)
            worklogs = processing_data['worklogs']
            return processing_data if worklogs.nil? || worklogs.empty?

            enriched_worklogs = worklogs.map do |worklog|
              time = worklog['time']
              # These are actually sprint names due to the way history and value_at_time work
              worklog.merge 'sprint_name' => Support.value_at_time(processing_data, 'sprints', time)
            end

            processing_data.merge 'worklogs' => enriched_worklogs
          end
          module_function :run
        end
      end
    end
  end
end
