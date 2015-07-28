require 'agilizer/issue'

module Agilizer
  module IssueAnalysis
    module Statistics

      def calculate(issues)
        %i(timespent
           time_original_estimate
           time_estimate
        ).inject({}) do |hash, value|
          hash[value] = {}
          %i(developer reviewer).each do |group|
            hash[value][group] = accumulate(value, group, issues)
          end
          hash
        end
      end
      module_function :calculate

      def accumulate(value, group, issues)
        issues.inject(Hash.new(0)) do |hash, issue|
          issue_group = issue.send(group)
          next(hash) if issue_group.nil?
          hash[issue_group] += (issue.send(value) || 0)
          hash
        end
      end
      module_function :accumulate
    end
  end
end
