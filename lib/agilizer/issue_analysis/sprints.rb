require 'agilizer/issue'

module Agilizer
  module IssueAnalysis

    # Analyses on sprints
    module Sprints

      # Return sprint names from issues.
      def names
        Issue.only(:sprints).map(&:sprints).flatten.map{|s| s['name']}.uniq
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
    end
  end
end
