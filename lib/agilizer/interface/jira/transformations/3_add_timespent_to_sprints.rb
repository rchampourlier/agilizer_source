module Agilizer
  module Interface
    module Jira
      module Transformations

        # Transformation to add timespent to sprints within
        # `processing_data['sprints']`
        module AddTimespentToSprints

          # If the `processing_data` doesn't contain both sprints
          # and worklogs, `processing_data` is returned without being
          # changed.
          def run(_source_data, processing_data)
            sprints = processing_data['sprints']
            worklogs = processing_data['worklogs']
            return processing_data if sprints.nil? || worklogs.nil?

            enriched_sprints = sprints.collect do |sprint|
              sprint_worklogs = worklogs_select(sprint, worklogs)
              sprint.merge('timespent' => worklogs_timespent(sprint_worklogs))
            end
            processing_data.merge 'sprints' => enriched_sprints
          end
          module_function :run

          # IMPLEMENTATION

          # @param sprint [Hash] a single sprint hash
          #   (e.g. `processing_data['sprints']`)
          # @param worklogs [Array] an array of worklogs
          #   (e.g. `processing_data['worklogs'])
          # @return [Array] a subset of worklogs containing only
          #   the ones matching the specified sprint
          def worklogs_select(sprint, worklogs)
            sprint_start = sprint['started_at']
            sprint_end = sprint['ended_at']
            return [] if sprint_start.nil?

            worklogs.select do |worklog|
              worklog_start = worklog['time']
              condition = worklog_start > sprint_start
              condition &&= worklog_start < sprint_end if sprint_end
              condition
            end
          end
          module_function :worklogs_select

          # @param worklogs [Array]
          # @return [Numeric] the total timespent for the passed worklogs
          def worklogs_timespent(worklogs)
            worklogs.inject(0) do |sum, worklog|
              sum + worklog['timespent']
            end
          end
          module_function :worklogs_timespent
        end
      end
    end
  end
end
