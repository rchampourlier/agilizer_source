require 'agilizer/issue'

module Agilizer
  module IssueAnalysis
    module Statistics

      # For each team member, calculates the total estimate of issues
      # where he's developer, and the total estimate of issues where
      # he's reviewer.
      #
      # Example:
      #   { 'team_member_1' => { 'developer' => 100, 'reviewer' => 200 } }...
      def time_estimate_by_developer_and_reviewer(issues)
        issues.inject({}) do |hash, issue|
          developer = issue.developer || 'unassigned'
          reviewer = issue.reviewer || 'unassigned'
          hash[developer] ||= { 'developer' => 0, 'reviewer' => 0}
          hash[reviewer] ||= { 'developer' => 0, 'reviewer' => 0}
          hash[developer]['developer'] += issue.time_estimate || 0
          hash[reviewer]['reviewer'] += issue.time_estimate || 0
          hash
        end
      end
      module_function :time_estimate_by_developer_and_reviewer

      # Returns the total time estimate for the specified issues.
      def total_time_estimate(issues)
        issues.inject(0) do |sum, issue|
          sum + (issue.time_estimate || 0)
        end
      end
      module_function :total_time_estimate

      # Time estimate for the specified issues at several moments,
      # by developer:
      #   - sprint start
      #   - sprint end
      #   - now
      #
      # Example:
      #   {
      #     'team_member_1' => { 'now' => 100, 'sprint_start' => 200, 'sprint_end' => 150 },
      #     ...
      #   }
      def time_estimate_by_developer_related_to_sprint(issues, sprint_name)
        issues.inject({}) do |hash, issue|
          developer = issue.developer || 'unassigned'
          sprint_data = issue.sprints.find { |sprint| sprint['name'] == sprint_name }
          next if sprint_data.nil?
          hash[developer] ||= { 'sprint_start' => 0, 'sprint_end' => 0, 'now' => 0 }
          hash[developer]['sprint_start'] += sprint_data['sprint_start']['time_estimate'] || 0
          hash[developer]['sprint_end'] += sprint_data['sprint_end']['time_estimate'] || 0
          hash[developer]['now'] += issue.time_estimate || 0
          hash
        end
      end
      module_function :time_estimate_by_developer_related_to_sprint

      # Example
      #   {
      #     'team_member_1' => { 'In Development' => 200, ... },
      #     ...
      #   }
      def timespent_by_status_by_developer(issues, sprint_name)
        issues.inject({}) do |hash, issue|
          developer = issue.developer || 'unassigned'
          sprint_data = issue.sprints.find { |sprint| sprint['name'] == sprint_name }
          next if sprint_data.nil?
          hash[developer] ||= { 'sprint_start' => 0, 'sprint_end' => 0, 'now' => 0 }
          hash[developer]['sprint_start'] += sprint_data['sprint_start']['time_estimate'] || 0
          hash[developer]['sprint_end'] += sprint_data['sprint_end']['time_estimate'] || 0
          hash[developer]['now'] += issue.time_estimate || 0
          hash
        end
      end
      module_function :timespent_by_status_by_developer
    end
  end
end
