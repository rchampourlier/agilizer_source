module Agilizer
  module Interface
    module Jira
      module Transformations
        module Support

          # @return [Numeric] sum of worklogs' timespent whose time
          #   is before the specified time.
          #   NB: returns nil if time is nil.
          def timespent_at_time(data, time)
            return nil if time.nil?

            period_worklogs = data['worklogs'].select do |worklog|
              worklog['time'] <= time
            end
            return nil if period_worklogs.empty?

            period_worklogs.inject(0) do |sum, worklog|
              sum + worklog['timespent']
            end
          end
          module_function :timespent_at_time
        end
      end
    end
  end
end
