require 'agilizer/interface/jira/transformations/support/value_at_time'
require 'agilizer/interface/jira/transformations/support/timespent_at_time'

module Agilizer
  module Interface
    module Jira
      module Transformations

        # Adds sprint information to the processing data.
        # For each sprint in issue, add sprint information to
        # the sprint entry.
        module AddSprintInformation

          def run(_source_data, processing_data)
            sprints = processing_data['sprints']
            enriched_sprints = sprints.map do |sprint|
              sprint_information = sprint_information(processing_data, sprint)
              sprint.merge sprint_information
            end
            processing_data.merge 'sprints' => enriched_sprints
          end
          module_function :run

          # IMPLEMENTATION FUNCTIONS

          # Returns detailed information related to the specified
          # sprint.
          #
          # Fives groups of information are returned:
          #   - 'during_sprint': [Hash]
          #     - 'added': [Bool] true if the issue was added to the
          #       sprint during the sprint,
          #     - 'removed': [Bool], same as 'added' for the issue
          #       removal,
          #     - 'timespent_change': difference between timespent:
          #       at start of sprint (or addition if the issue was
          #       added during the sprint), and at end of sprint
          #       (or removal if the issue was removed during sprint),
          #     - 'time_estimate_change': same as 'timespent_change',
          #       for 'time_estimate',
          #     - 'time_original_estimate_change': same for
          #       'time_original_estimate'.
          #
          #   - 'addition_to_sprint', 'removal_from_sprint':
          #     - 'time': [Time]
          #     - 'time_estimate': [Numeric]
          #     - 'time_original_estimate': [Numeric]
          #     - 'status': [String]
          #
          #   - 'sprint_start', 'sprint_end'
          #     - 'time_estimate': [Numeric]
          #     - 'time_original_estimate': [Numeric]
          #     - 'status': [String]
          #
          # @params sprint [Hash]
          #   Hash of the sprint base information: name, started_at,
          #   closed_at, state.
          #   May be retrieved from the issue's "sprints" field.
          # @return [Hash]
          #
          def sprint_information(data, sprint)
            sprint_name = sprint['name']
            sprint_histories = sprint_related_histories(data, sprint_name)

            # sprint_histories contains all histories related to the
            # specified sprint, including the first one where the sprint
            # is associated to the story, and the last one.
            # The story may have been directly associated to the sprint
            # on creation, or be closed still associated to the sprint,
            # so we must check if the extreme items are on the field
            # "sprints" to determine if the issue was added/removed
            # during the sprint. For ex. if the first history is not
            # on the "sprints" field, this mean the issue has been
            # associated to the sprint at its creation.

            addition_history = (
              if sprint_histories.empty? || sprint_histories.first['field'] != 'sprints' then nil
              else sprint_histories.first
              end
            )

            removal_history = (
              if sprint_histories.empty? || sprint_histories.last['field'] != 'sprints' then nil
              else sprint_histories.first
              end
            )

            sprint_start = sprint ? sprint['started_at'] : nil
            addition_time = (
              if addition_history
                addition_history['time']
              elsif sprint_start && data['created_at'] > sprint_start
                data['created_at']
              else nil
              end
            )
            added_during_sprint = (
              if addition_time.nil? then false
              elsif sprint_start then addition_time > sprint_start
              else false
              end
            )

            sprint_end = sprint ? sprint['ended_at'] : nil
            removal_time = (
              if removal_history then removal_history['time']
              else nil
              end
            )
            removed_during_sprint = (
              if removal_time && sprint_end
                removal_time < sprint_end
              else false
              end
            )

            # When added
            time_estimate_when_added = Support.value_at_time(data, 'time_estimate', addition_time)
            time_original_estimate_when_added = Support.value_at_time(data, 'time_original_estimate', addition_time)
            status_when_added = Support.value_at_time(data, 'status', addition_time)
            timespent_when_added = Support.timespent_at_time(data, addition_time)

            # When removed
            time_estimate_when_removed = Support.value_at_time(data, 'time_estimate', removal_time)
            time_original_estimate_when_removed = Support.value_at_time(data, 'time_original_estimate', removal_time)
            status_when_removed = Support.value_at_time(data, 'status', removal_time)
            timespent_when_removed = Support.timespent_at_time(data, removal_time)

            # At sprint start
            time_estimate_at_sprint_start =
              sprint_start ? Support.value_at_time(data, 'time_estimate', sprint_start) : nil
            time_original_estimate_at_sprint_start =
              sprint_start ? Support.value_at_time(data, 'time_original_estimate', sprint_start) : nil
            status_at_sprint_start = sprint_start ? Support.value_at_time(data, 'status', sprint_start) : nil
            timespent_at_sprint_start = Support.timespent_at_time(data, sprint_start)

            # At sprint end
            end_time = sprint_start ? (sprint_end || Time.now) : nil
            time_estimate_at_sprint_end = Support.value_at_time(data, 'time_estimate', end_time)
            time_original_estimate_at_sprint_end = Support.value_at_time(data, 'time_original_estimate', end_time)
            status_at_sprint_end = Support.value_at_time(data, 'status', end_time)
            timespent_at_sprint_end = Support.timespent_at_time(data, end_time)

            # During sprint
            from_phase = added_during_sprint ? 'addition_to_sprint' : 'sprint_start'
            to_phase = removed_during_sprint ? 'removal_from_sprint' : 'sprint_end'

            phases_information = {
              'addition_to_sprint' => {
                'time' => addition_time,
                'time_estimate' => time_estimate_when_added,
                'time_original_estimate' => time_original_estimate_when_added,
                'timespent' => timespent_when_added,
                'status' => status_when_added
              },

              'removal_from_sprint' => {
                'time' => removal_time,
                'time_estimate' => time_estimate_when_removed,
                'time_original_estimate' => time_original_estimate_when_removed,
                'timespent' => timespent_when_removed,
                'status' => status_when_removed
              },

              'sprint_start' => {
                'time_estimate' => time_estimate_at_sprint_start,
                'time_original_estimate' => time_original_estimate_at_sprint_start,
                'timespent' => timespent_at_sprint_start,
                'status' => status_at_sprint_start
              },

              'sprint_end' => {
                'time_estimate' => time_estimate_at_sprint_end,
                'time_original_estimate' => time_original_estimate_at_sprint_end,
                'timespent' => timespent_at_sprint_end,
                'status' => status_at_sprint_end
              }
            }

            during_sprint_information = {
              'added' => added_during_sprint,
              'removed' => removed_during_sprint
            }
            %w(timespent time_estimate time_original_estimate).each do |attribute|
              from = phases_information[from_phase][attribute]
              to = phases_information[to_phase][attribute]
              attribute_change = from.nil? && to.nil? ? nil : (to || 0) - (from || 0)
              during_sprint_information.merge!("#{attribute}_change" => attribute_change)
            end

            { 'during_sprint' => during_sprint_information }.merge(phases_information)
          end
          module_function :sprint_information

          # Returns data\'s history items related to the named
          # sprint.
          #
          # Returns all histories between the addition of the sprint
          # to the issues' sprints and its removal.
          #
          # NB:
          #   - will return all histories if there is no history on
          #     the sprints field and the named sprint is the latest
          #     entry in the data's sprints field (otherwise we
          #     assume it's not the current sprint - but this case
          #     is unlikely - and will be caught - because there would
          #     be some history on the sprints field)
          #   - when reading the sprints value in history, we consider
          #     only the latest value in the array to be the current
          #     sprint, because JIRA will leave all previous sprints
          #     in the value too.
          def sprint_related_histories(data, sprint_name)
            histories = data['history']
            raise 'data must have been enriched with history' if histories.nil?

            sprint_histories = HashOp::Filter.filter histories, 'field' => 'sprints'

            if sprint_histories.empty?
              return histories if data['sprints'].length == 1 && data['sprints'].first['name'] == sprint_name
              return []
            end

            associated_to_sprint = false
            histories.select do |history|
              if !associated_to_sprint && history['field'] == 'sprints' && history['to'].last == sprint_name
                associated_to_sprint = true
              elsif associated_to_sprint && history['field'] == 'sprints' && history['to'].last != sprint_name
                associated_to_sprint = false
                true
              else
                associated_to_sprint
              end
            end
          end
          module_function :sprint_related_histories
        end
      end
    end
  end
end
