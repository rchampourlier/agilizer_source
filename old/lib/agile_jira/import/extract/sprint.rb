module Agilizer
  module Process
    module Extract
      module Sprint

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
        # @return [Hash]
        #
        def information(essence, sprint_name)
          sprint_histories = related_histories(essence, sprint_name)

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
            else sprint_histories.first end
          )

          removal_history = (
            if sprint_histories.empty? || sprint_histories.last['field'] != 'sprints' then nil
            else sprint_histories.first end
          )

          sprint = essence['sprints'].find { |s| s['name'] == sprint_name }

          sprint_start = sprint ? sprint['started_at'] : nil
          addition_time = (
            if addition_history
              addition_history['time']
            elsif sprint_start && essence['created_at'] > sprint_start
              essence['created_at']
            else nil end
          )
          added_during_sprint = (
            if addition_time.nil? then false
            elsif sprint_start then addition_time > sprint_start
            else false end
          )

          sprint_end = sprint ? sprint['ended_at'] : nil
          removal_time = (
            if removal_history then removal_history['time']
            else nil end
          )
          removed_during_sprint = (
            if removal_time && sprint_end
              removal_time < sprint_end
            else false
            end
          )

          # When added
          time_estimate_when_added = Extract.value_at_time(essence, 'time_estimate', addition_time)
          time_original_estimate_when_added = Extract.value_at_time(essence, 'time_original_estimate', addition_time)
          status_when_added = Extract.value_at_time(essence, 'status', addition_time)
          timespent_when_added = Extract.timespent_at_time(essence, addition_time)

          # When removed
          time_estimate_when_removed = Extract.value_at_time(essence, 'time_estimate', removal_time)
          time_original_estimate_when_removed = Extract.value_at_time(essence, 'time_original_estimate', removal_time)
          status_when_removed = Extract.value_at_time(essence, 'status', removal_time)
          timespent_when_removed = Extract.timespent_at_time(essence, removal_time)

          # At sprint start
          time_estimate_at_sprint_start = sprint_start ? Extract.value_at_time(essence, 'time_estimate', sprint_start) : nil
          time_original_estimate_at_sprint_start = sprint_start ? Extract.value_at_time(essence, 'time_original_estimate', sprint_start) : nil
          status_at_sprint_start = sprint_start ? Extract.value_at_time(essence, 'status', sprint_start) : nil
          timespent_at_sprint_start = Extract.timespent_at_time(essence, sprint_start)

          # At sprint end
          end_time = sprint_start ? (sprint_end || Time.now) : nil
          time_estimate_at_sprint_end = Extract.value_at_time(essence, 'time_estimate', end_time)
          time_original_estimate_at_sprint_end = Extract.value_at_time(essence, 'time_original_estimate', end_time)
          status_at_sprint_end = Extract.value_at_time(essence, 'status', end_time)
          timespent_at_sprint_end = Extract.timespent_at_time(essence, end_time)

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
        module_function :information

        # Returns essence\'s history items related to the named
        # sprint.
        #
        # Returns all histories between the addition of the sprint
        # to the issues' sprints and its removal.
        #
        # NB:
        #   - will return all histories if there is no history on
        #     the sprints field and the named sprint is the latest
        #     entry in the essence's sprints field (otherwise we
        #     assume it's not the current sprint - but this case
        #     is unlikely - and will be caught - because there would
        #     be some history on the sprints field)
        #   - when reading the sprints value in history, we consider
        #     only the latest value in the array to be the current
        #     sprint, because JIRA will leave all previous sprints
        #     in the value too.
        def related_histories(essence, sprint_name)
          histories = essence['history']
          raise 'Essence must have been enriched with history' if histories.nil?

          sprint_histories = HashFilter.filter histories, 'field' => 'sprints'

          if sprint_histories.empty?
            return histories if essence['sprints'].length == 1 && essence['sprints'].first['name'] == sprint_name
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
        module_function :related_histories

        # @param sprint [Hash] a single sprint hash from
        #   Issue.essence['sprints']
        # @param worklogs [Array] an array of worklogs from
        #   Issue.essence['worklogs']
        # @return [Array] a subset of worklogs containing only
        #   the ones matching the specified sprint
        def select_worklogs(sprint, worklogs)
          sprint_start = sprint['started_at']
          sprint_end = sprint['ended_at']

          return [] if sprint_start.nil?
          worklogs.select do |worklog|
            worklog_start = worklog['time']
            condition = worklog_start > sprint_start
            condition &&= worklog_start < sprint_end if sprint_end
            condition
          end
        end
        module_function :select_worklogs
      end
    end
  end
end
