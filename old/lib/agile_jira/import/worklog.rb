module Agilizer
  module Process

    # Provides functions to perform operations on worklog
    # entries from Issue essence['worklogs'] or on the
    # essence itself.
    #
    # NB: this module doesn't process worklogs from
    # Issue's data.
    module Worklog

      # @param worklogs [Array]
      # @param from [Time]
      # @param to [Time]
      # @return [Array] a subset of worklogs, containing the one
      #   whose time is between from and to
      def filter_between(worklogs, from, to)
        worklogs.select do |worklog|
          condition = true
          condition &&= worklog['time'] >= from if from
          condition &&= worklog['time'] <= to if to
          condition
        end
      end
      module_function :filter_between

      # @param worklogs [Array]
      # @return [Numeric] the total timespent for the passed worklogs
      def timespent(worklogs)
        worklogs.inject(0) do |sum, worklog|
          sum + worklog['timespent']
        end
      end
      module_function :timespent

      # @param [Array] worklogs an array of worklog hash objects
      #   from an issue's essence.
      #
      # @return [Array] hashes:
      #   'author' => the author's key
      #   'timespent' => the timespent in seconds
      #
      # Usage:
      #   worklogs = Issue.last.essence['worklogs']
      #   Worklog.timespent_per_author(worklogs)
      #
      def timespent_per_author(worklogs)
        worklogs_per_author = worklogs.inject(Hash.new(0)) do |hash, worklog|
          hash[worklog['author']] += worklog['timespent']
          hash
        end
        worklogs_per_author.collect do |key, value|
          {
            'author' => key,
            'timespent' => value
          }
        end
      end
      module_function :timespent_per_author

      # Returns essence's worklogs, where each worklog hash
      # has been enriched with the issue key and summary
      #
      # @param essence [Hash]
      # @return [Array] enriched worklogs (hashes)
      def rich_worklogs(essence)
        worklogs = essence['worklogs']
        worklogs.map do |worklog|
          worklog.merge(
            'issue_key' => essence['key'],
            'issue_summary' => essence['summary']
          )
        end
      end
      module_function :rich_worklogs

      # If a worklog created time and started time are equal
      # and timespent is not null, it's probably a false entry
      # because we usually don't enter worklogs before doing them.
      #
      # This method will rewrite each worklog to replace 'created_at'
      # and 'started_at' by a single 'time' entry, which is:
      #   - the value of 'started_at' if different from 'created_at',
      #   - the value of 'started_at' minus the value of 'timespent'
      #     otherwise.
      def set_time(worklog)
        created_at = worklog['created_at']
        started_at = worklog['started_at']
        timespent = worklog['timespent'] || 0

        time = started_at < created_at ? started_at : created_at - timespent

        worklog = worklog.except('created_at', 'started_at')
        worklog = worklog.merge('time' => time)
        worklog
      end
      module_function :set_time
    end
  end
end
