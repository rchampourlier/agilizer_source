require 'agilizer/issue'
require 'hash_op/deep'
require 'hash_op/math'
require 'hash_op/read'
require 'hash_op/filter'

module Agilizer
  module IssueAnalysis

    # Calculate statistics on issues
    module Statistics

      # For each team member, calculates the total estimate of issues
      # where he's developer, and the total estimate of issues where
      # he's reviewer.
      #
      # Example:
      #   { 'team_member_1' => { 'developer' => 100, 'reviewer' => 200 } }...
      # TODO refactor
      def time_estimate_by_developer_and_reviewer(issues)
        issues.each_with_object({}) do |issue, hash|
          developer = issue.developer || 'unassigned'
          reviewer = issue.reviewer || 'unassigned'
          hash[developer] ||= { 'developer' => 0, 'reviewer' => 0 }
          hash[reviewer] ||= { 'developer' => 0, 'reviewer' => 0 }
          hash[developer]['developer'] += issue.time_estimate || 0
          hash[reviewer]['reviewer'] += issue.time_estimate || 0
        end
      end
      module_function :time_estimate_by_developer_and_reviewer

      # Returns the total time estimate for the specified issues.
      # TODO refactor
      def total_time_estimate(issues)
        issues.inject(0) do |sum, issue|
          sum + (issue.time_estimate || 0)
        end
      end
      module_function :total_time_estimate

      #
      # Usage:
      #   sprint_data(
      #     issues,
      #     sprint_name,
      #     'developer',
      #     %w(sprint_start sprint_end),
      #     'time_estimate'
      #   )
      #
      # Example of return value:
      # [{
      #   'developer' => 'some.developer',
      #   'sprint_start' => 200,
      #   'sprint_end' => 150,
      #   'now' => 100
      # }, ...]
      #
      # TODO 'now' value should not be calculated here
      def sum_sprint_data(issues, sprint_name, issue_grouping_path, sprint_data_groups, value_path)
        issues.each_with_object({}) do |issue, hash|
          sprint_data = issue.sprints.find { |sprint| sprint['name'] == sprint_name }
          next if sprint_data.nil?

          issue_grouping_value = HashOp::Deep.fetch(issue.attributes, issue_grouping_path)

          if hash[issue_grouping_value].nil?
            hash[issue_grouping_value] = {
              issue_grouping_path => issue_grouping_value,
              'now' => 0
            }
            sprint_data_groups.each do |sprint_data_group|
              hash[issue_grouping_value].merge! sprint_data_group => 0
            end
          end

          sprint_data_groups.each do |sprint_data_group|
            hash[issue_grouping_value][sprint_data_group] += sprint_data[sprint_data_group][value_path] || 0
          end
          hash[issue_grouping_value]['now'] += issue.attributes[value_path] || 0
        end.values
      end
      module_function :sum_sprint_data

      def timespent(issues, sprint_name, grouping_attributes)
        worklogs = issues.map(&:worklogs).flatten
        sprint_worklogs = HashOp::Filter.filter(worklogs, 'sprint_name' => sprint_name)
        HashOp::Math.sum_on_groups(sprint_worklogs, grouping_attributes, %w(timespent))
      end
      module_function :timespent
    end
  end
end
