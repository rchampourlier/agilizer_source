require 'hash_operations/hash_math'
require 'hash_operations/hash_merge'

module Agilizer
  module Process

    # Enrich the essence of an issue.
    #
    # The essence of an issue is obtained by enriching the result of the
    # issue's data mapping.
    #
    # Enrichments must be independent from each other.
    module Enrich

      # For each worklog of the essence, add 'status' corresponding
      # to the status of the issue at the time of the worklog.
      #
      # NB:
      #   - if the essence doesn't contain worklogs, the essence is
      #     returned unchanged,
      #   - if the essence doesn't contain history (added by
      #     Improve::add_simple_history), an error is raised.
      def add_status_to_worklogs(essence, data)
        worklogs = essence['worklogs']
        return essence if worklogs.blank?

        enriched_worklogs = worklogs.map do |worklog|
          time = worklog['time']
          status = Extract::value_at_time(essence, 'status', time)
          worklog.merge 'status' => status
        end

        essence.merge 'worklogs' => enriched_worklogs
      end
      module_function :add_status_to_worklogs

      # For each worklog of the essence, add 'sprint_name' corresponding
      # to the sprint_name of the issue at the time of the worklog.
      def add_sprint_name_to_worklogs(essence, data)
        worklogs = essence['worklogs']
        return essence if worklogs.blank?

        enriched_worklogs = worklogs.map do |worklog|
          time = worklog['time']
          sprint_names = Extract::value_at_time(essence, 'sprints', time) || []
          worklog.merge 'sprint_name' => sprint_names.last
        end

        essence.merge 'worklogs' => enriched_worklogs
      end
      module_function :add_sprint_name_to_worklogs

      # @param [Hash] essence
      # @return [Hash] enriched essence content, where
      #   sprints have been added the timespent
      #
      # If the essence content doesn't contain both sprints
      # and worklogs, nothing is added.
      def add_timespent_to_sprints(essence)
        sprints = essence['sprints']
        worklogs = essence['worklogs']
        return essence if sprints.nil? || worklogs.nil?

        enriched_sprints = sprints.collect do |sprint|
          sprint_worklogs = Extract::Sprint.select_worklogs(sprint, worklogs)
          sprint.merge('timespent' => Worklog.timespent(sprint_worklogs))
        end
        essence.merge 'sprints' => enriched_sprints
      end
      module_function :add_timespent_to_sprints

      def add_timespent_per_status(essence)
        timespent_per_status = Extract.timespent_per_status(essence)
        essence.merge 'timespent_per_status' => timespent_per_status
      end
      module_function :add_timespent_per_status

      # For each sprint in essence, add sprint information (through
      # Extract::Sprint::information) to the sprint entry.
      def add_sprint_information(essence)
        sprints = essence['sprints']
        enriched_sprints = sprints.map do |sprint|
          sprint_name = sprint['name']
          sprint_information = Extract::Sprint.information(essence, sprint_name)
          sprint.merge sprint_information
        end
        essence.merge 'sprints' => enriched_sprints
      end
      module_function :add_sprint_information

      def add_final_fix_version(essence)
        fix_versions = essence['fix_versions']
        final_fix_version = HashFilter.filter(fix_versions, 'released' => true).last
        essence.merge 'final_fix_version' => final_fix_version
      end
      module_function :add_final_fix_version
    end
  end
end
