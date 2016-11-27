module Agilizer
  module Interface
    module Jira
      module Transformations

        # Replaces "started_at" and "created_at" by a single "time"
        # entry which better represent the time where the work
        # logged took place.
        module SetWorklogTime

          def run(_source_data, processing_data)
            worklogs = processing_data["worklogs"]
            return processing_data if worklogs.nil? || worklogs.empty?

            improved_worklogs = worklogs.map do |worklog|
              process(worklog)
            end

            processing_data.merge "worklogs" => improved_worklogs
          end
          module_function :run

          # IMPLEMENTATION

          # If a worklog created time and started time are equal
          # and timespent is not null, it"s probably a false entry
          # because we usually don"t enter worklogs before doing them.
          #
          # This method will rewrite each worklog to replace "created_at"
          # and "started_at" by a single "time" entry, which is:
          #   - the value of "started_at" if different from "created_at",
          #   - the value of "started_at" minus the value of "timespent"
          #     otherwise.
          def process(worklog)
            created_at = worklog["created_at"]
            started_at = worklog["started_at"]
            timespent = worklog["timespent"] || 0

            time = started_at < created_at ? started_at : created_at - timespent
            worklog = worklog.reject { |k, _| %w(created_at started_at).include?(k) }
            worklog = worklog.merge("time" => time)
            worklog
          end
          module_function :process
        end
      end
    end
  end
end
