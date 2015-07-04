require 'hash_operations/hash_deep_access'
require 'hash_operations/hash_filter'
require 'hash_operations/hash_grouping'
require 'process/extract/history'
require 'process/extract/sprint'

module Agilizer
  module Process

    # Extracts non-trivial information from Issue's essence.
    module Extract

      def sprint_names(essence)
        essence['sprints'].map { |sprint| sprint['name'] }
      end
      module_function :sprint_names

      # @param essence [Hash] the essence must:
      #   - include worklogs (Process::map)
      #
      # @return [Hash]
      #   - key: the status
      #   - value: the timespent during the status
      #
      def timespent_per_status(essence)
        worklogs = essence['worklogs']
        raise 'Essence must contain the worklogs' if worklogs.nil?

        HashMath.sum_on_groups(worklogs, 'status', 'timespent')
      end
      module_function :timespent_per_status

      # @return [Numeric] sum of worklogs' timespent whose time
      #   is before the specified time.
      #   NB: returns nil if time is nil.
      def timespent_at_time(essence, time)
        return nil if time.nil?

        period_worklogs = essence['worklogs'].select do |worklog|
          worklog['time'] <= time
        end
        return nil if period_worklogs.empty?

        period_worklogs.inject(0) do |sum, worklog|
          sum + worklog['timespent']
        end
      end
      module_function :timespent_at_time

      # Return the value for an issue (from its data)
      # for a given field at a given time.
      #
      # Rules:
      #   - if no history on this field is found, then the value is
      #     the current (and initial) value of the field
      #   - if there is at least one history before the specified
      #     time or at the same time, the value is the 'to' value
      #     of this history
      #   - if there is no history before the specified time, but
      #     there is at least one history after the specified time,
      #     the value is the 'from' value of this history
      #
      # @param essence [Hash] an Issue.essence, which must have already
      #   been enriched with Improve::add_simple_history
      #
      # @param field [String] must be a mappable field (i.e. defined
      #   in Agilizer::Process::MAPPING)
      #
      # @param time [Time]
      #   - returns nil if time is nil
      #
      def value_at_time(essence, field, time)
        return nil if time.nil?

        raise 'Essence must already have been enriched with Improve::add_simple_history' unless essence['history']

        history = essence['history']
        field_history = HashFilter.filter history, { 'field' => field }

        return essence[field] if field_history.empty?

        first_history_before_time = field_history.reverse.find do |s_history|
          s_history['time'] <= time
        end
        return first_history_before_time['to'] if first_history_before_time

        first_history_after_time = field_history.find do |s_history|
          s_history['time'] > time
        end
        return first_history_after_time['from'] if first_history_after_time

        nil
      end
      module_function :value_at_time
    end
  end
end
