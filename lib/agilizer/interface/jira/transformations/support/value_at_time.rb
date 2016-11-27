# frozen_string_literal: true
module Agilizer
  module Interface
    module Jira
      module Transformations
        module Support

          VALUE_AT_TIME_AUTHORIZED_FIELDS = %w(
            sprints
            time_estimate
            time_original_estimate
            status
            assignee
          ).freeze

          # Return the value for an issue (from its data)
          # for a given field at a given time.
          #
          # The value is read from the issue"s history (which must
          # be added using `AddSimpleHistory` transformation prior
          # to using this method).
          #
          # If can only be used for `VALUE_AT_TIME_AUTHORIZED_FIELDS`
          # (see `AddSimpleHistory`).
          #
          # Rules:
          #   - if no history on this field is found, then the value is
          #     the current (and initial) value of the field
          #   - if there is at least one history before the specified
          #     time or at the same time, the value is the "to" value
          #     of this history
          #   - if there is no history before the specified time, but
          #     there is at least one history after the specified time,
          #     the value is the "from" value of this history
          #
          # @param processing_data [Hash] processing data from transformations,
          #   already processed by `AddSimpleHistory` because `history` value_at_time
          #   is used.
          # @param field [String] the field to determine the value for
          # @param time [Time] the time at which determines the value for the field
          #
          # @return [Object] the value for the field at the specified time according
          #   to the history present in processing_data. If `time` is nil, returns nil.
          #
          def value_at_time(processing_data, field, time)
            raise Error, "Invalid field \"#{field}\"" unless VALUE_AT_TIME_AUTHORIZED_FIELDS.include?(field)

            return nil if time.nil?
            history = processing_data["history"]
            raise Error, "Processing data must have been processed by `AddSimpleHistory`" if history.nil?

            field_history = HashOp::Filter.filter history, "field" => field
            if field_history.empty?
              if field == "sprints"
                sprints = processing_data["sprints"]
                return sprints.any? ? sprints.last["name"] : nil
              end
              return processing_data[field]
            end

            first_history_before_time = field_history.reverse.find do |history_item|
              history_item["time"] <= time
            end
            return Array(first_history_before_time["to"]).last if first_history_before_time
            # We return the last of an array because for the "sprints" field,
            # the field may be a list of sprint names instead of a single value.

            first_history_after_time = field_history.find do |history_item|
              history_item["time"] > time
            end
            return Array(first_history_after_time["from"]).last if first_history_after_time
            # Same comment as above.

            nil
          end
          module_function :value_at_time
        end
      end
    end
  end
end
