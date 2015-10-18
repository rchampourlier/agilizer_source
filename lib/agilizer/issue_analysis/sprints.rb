require 'agilizer/issue'

module Agilizer
  module IssueAnalysis

    # Analyses on sprints
    module Sprints

      # Return sprint names from issues.
      def names
        Issue.only(:sprints).map(&:sprints).flatten.map{|s| s['name']}.uniq.sort.reverse
      end
      module_function :names

      def current_sprint_name
        active_sprint_query = { sprints: { :$elemMatch => { state: 'ACTIVE' } } }
        current_sprint_issue = Issue.only(:sprints).where(active_sprint_query).first
        fail 'No active sprint' if current_sprint_issue.nil?

        current_sprint = current_sprint_issue.sprints.find { |sprint| sprint['state'] = 'ACTIVE' }
        current_sprint['name']
      end
      module_function :current_sprint_name

      # Return reports for the last (most recent) `last` sprints.
      # @param last [Numeric] number of sprints to provide reports for
      def report(sprint_name)
        sprint_issues = Issue.with_filter(sprint: { name: sprint_name })
        sprint_report = IssueAnalysis::Statistics.sprint_data(
          sprint_issues,
          sprint_name,
          'developer',
          %w(sprint_start sprint_end),
          'time_estimate'
        )
        sprint_report.map { |report_item| report_item.merge('sprint_name' => sprint_name) }
      end
      module_function :report
    end
  end
end
