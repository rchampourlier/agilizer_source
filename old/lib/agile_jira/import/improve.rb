module Agilizer
  module Process

    # Functions to perform corrections on content
    # of issues.
    module Improve

      # Merge Extract::History.simplify(data) into
      #   mapped_data['history']
      def add_simple_history(mapped_data, data)
        simple_history = Extract::History.simplify(data)
        mapped_data.merge 'history' => simple_history
      end
      module_function :add_simple_history

      # Replaces 'started_at' and 'created_at' by a single 'time'
      # entry which better represent the time where the work
      # logged took place.
      #
      # See Process::Worklog::set_time(worklog) for more details.
      def set_worklog_time(mapped_data)
        worklogs = mapped_data['worklogs']
        return mapped_data if worklogs.blank?

        improved_worklogs = worklogs.map do |worklog|
          Process::Worklog.set_time(worklog)
        end

        mapped_data.merge 'worklogs' => improved_worklogs
      end
      module_function :set_worklog_time
    end
  end
end
