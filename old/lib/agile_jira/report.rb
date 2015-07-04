module Agilizer
  class Report

    def self.timespent_vs_time_original_estimate(issues)
      issues.inject({}) do |hash, issue|
        essence = issue.essence
        hash[essence['key']] = essence.slice(*%w(timespent time_original_estimate))
        hash
      end
    end
  end
end
