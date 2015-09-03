require 'agilizer/api/app'
require 'agilizer/issue_analysis/statistics'

module Agilizer
  module API
    class App
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
        end
      end
    end
  end
end
