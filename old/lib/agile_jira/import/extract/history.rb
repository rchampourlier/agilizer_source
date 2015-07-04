require 'hash_operations/hash_filter'

module Agilizer
  module Process
    module Extract

      # Extract history contents from Issue's data.changelog.histories
      # values.
      module History

        # Return simplified and flattened histories
        # (from data.changelog.histories).
        #
        # Create an item for each supported item of each history,
        # adding the history's creation time on each time.
        #
        # Supported items are items for fields:
        #   - 'Sprint', which is mapped to 'sprints'
        #   - 'timeestimate' => 'time_estimate'
        #   - 'timeoriginalestimate' => 'time_original_estimate'
        #
        # @param [Hash] Issue's data
        # @return [Array] hashes representing history
        #   items, simplified:
        #     'field' => history.items.field
        #     'to' => history.items.to
        #     'time' => history.created
        #   sorted on 'time'
        #
        def simplify(data)
          histories = HashDeepAccess.fetch data, 'changelog.histories'

          simplified_histories = histories.map do |history|
            items = history['items']
            items.map do |item|
              case (field = item['field'])

              when 'Sprint'
                field = 'sprints'
                from = item['fromString']
                to = item['toString']
                from = from ? from.split(', ') : nil
                to = to ? to.split(', ') : nil

              when /time(.*)estimate/
                field = (field == 'timeestimate') ? 'time_estimate' : 'time_original_estimate'
                from = item['from'] ? item['from'].to_i : nil
                to = item['to'] ? item['to'].to_i : nil

              when 'status'
                from = item['fromString']
                to = item['toString']

              when 'assignee'
                from = item['from']
                to = item['to']

              else; field = nil
              end

              if field
                {
                  'field' => field,
                  'from' => from,
                  'to' => to,
                  'time' => Time.parse(history['created'])
                }
              end
            end.compact
          end.flatten

          simplified_histories.sort_by do |history|
            history['time']
          end
        end
        module_function :simplify
      end
    end
  end
end
