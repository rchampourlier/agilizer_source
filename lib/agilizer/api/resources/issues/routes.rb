require 'agilizer/api'

module Agilizer
  class API
    resource :issues do

      desc <<-END
      Returns issues according to the specified filter.

      Payload: optional, JSON, filter as proposed by
        filter.possible in the response.

      Returns:
          {
            issues: {
              entries: [ ... ],
              start: Numeric,
              count: Numeric,
              total: Numeric
            }
            filter: {
              applied: { ... },
              possible: { ... }
            }
          }
      END
      get rabl: 'issues/collection' do
        @issues = Issue.limit(100)
      end
    end
  end
end
