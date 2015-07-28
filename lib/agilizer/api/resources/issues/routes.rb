require 'agilizer/api'
require 'agilizer/issue_analysis/statistics'

module Agilizer
  class API
    resource :issues do

      desc <<-END
      Returns issues according to the specified filter.

      Payload: optional, JSON, filter as proposed by
        filter.possible in the response.
      END
      get rabl: 'issues/collection' do
        @applied_filter = params[:filter] || {}
        @available_filter = Issue.available_filter
        @issues = Issue.with_filter(@applied_filter).all
        @statistics = IssueAnalysis::Statistics.calculate(@issues)
      end
    end
  end
end
