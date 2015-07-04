require 'hash_op'

module Agilizer
  module Interface
    module Jira
      module Transformations

        # Simplify history from `data.changelog.histories` and add simplified
        # history entries in `history`.
        module AddSimpleHistory

          # Returns simplified and flattened histories
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
          def run(source_data, processing_data)
            histories = HashOp::DeepAccess.fetch source_data, 'changelog.histories'

            simplified_histories = histories.map do |history|
              items = history['items']
              items.map do |item|
                simplified_item = simplify_history_item(item)
                simplified_item.merge 'time' => Time.parse(history['created']) if simplified_item
              end.compact
            end.flatten

            simplified_histories.sort_by do |history|
              history['time']
            end

            processing_data.merge 'history' => simplified_histories
          end
          module_function :run

          # IMPLEMENTATION

          def simplify_history_item(item)
            simplified_item =
              case item['field']
              when 'Sprint' then simplify_history_item_sprint(item)
              when /time(.*)estimate/ then simplify_history_item_time_estimate(item)
              when 'status' then simplify_history_item_status(item)
              when 'assignee' then simplify_history_item_assignee(item)
            end
          end
          module_function :simplify_history_item

          def simplify_history_item_sprint(item)
            from = item['fromString']
            to = item['toString']
            from = from ? from.split(', ') : nil
            to = to ? to.split(', ') : nil
            {
              'field' => 'sprints',
              'from' => from,
              'to' => to
            }
          end
          module_function :simplify_history_item_sprint

          def simplify_history_item_time_estimate(item)
            {
              'field' => (item['field'] == 'timeestimate') ? 'time_estimate' : 'time_original_estimate',
              'from' => item['from'] ? item['from'].to_i : nil,
              'to' => item['to'] ? item['to'].to_i : nil
            }
          end
          module_function :simplify_history_item_time_estimate

          def simplify_history_item_status(item)
            {
              'field' => 'status',
              'from' => item['fromString'],
              'to' => item['toString']
            }
          end
          module_function :simplify_history_item_status

          def simplify_history_item_assignee(item)
            {
              'field' => 'assignee',
              'from' => item['from'],
              'to' => item['to']
            }
          end
          module_function :simplify_history_item_assignee
        end
      end
    end
  end
end
