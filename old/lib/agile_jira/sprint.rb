module Agilizer
  class Sprint

    # Returns all sprints identified in issues.
    # Sprints are sorted on "name", in ascending
    # order.
    #
    # @return [Array] hashes representing sprints,
    #   containing the following attributes:
    #     - name
    #     - started_at
    #     - ended_at
    #     - state
    def self.all
      sprints_by_updated_at = Search.sprints_by_essence_updated_at
      all_occurrences = sprints_by_updated_at.map do |updated_at, sprints|
        sprints.map do |s|
          sprint_hash = s.slice('name', 'started_at', 'ended_at', 'state')

          # Add the essence's updated_at to enable filtering
          # if several copies of the same sprint appear.
          sprint_hash.merge 'updated_at' => updated_at
        end
      end.flatten

      # Remove the duplicate sprints, keeping the latest one
      grouped_occurrences = all_occurrences.group_by {|s| s['name'] }
      result = grouped_occurrences.map do |name, occurrences|
        last = occurrences.sort_by { |o| o['updated_at'] }.last
        last.except('updated_at')
      end

      result.sort_by { |i| i['name'] }
    end

    # @todo move to somewhere else, this is only
    #   sugar-syntax
    def self.last
      started = all.select { |s| !!s['started_at'] }
      sorted = started.sort_by { |s| s['started_at'] }
      current_index = sorted.index { |s| s['name'] == current['name'] }
      sorted[current_index - 1]
    end

    # @todo move to somewhere else, this is only
    #   sugar-syntax
    def self.current
      all.select {|s| s['state'] == 'ACTIVE'}.first
    end

    # @todo move to somewhere else, this is only
    #   sugar-syntax
    def self.names
      all.map { |s| s['name'] }.uniq
    end

    # @param sprint_name [String]
    # @return [Hash] details on the sprint:
    #   - name
    #   - started_at
    #   - ended_at
    def self.details(sprint_name)
      { 'name' => sprint_name }
        .merge(details_from_issues(sprint_name))
    end

    # Returns the information about the sprint from
    # the essence.
    def self.issue_sprint_information(essence, sprint_name)
      essence['sprints'].find do |sprint|
        sprint['name'] == sprint_name
      end
    end

    def self.details_from_issues(sprint_name)
      essence = Search.essences_for_sprint(sprint_name).first
      details = issue_sprint_information(essence, sprint_name)
      details.slice 'started_at', 'ended_at'
    end

    # Calculates statistics for the specified sprint on the specified
    # essences.
    #
    # @param essences [Array] of issue essence hashes
    # @param sprint_name [String]
    # @return [Hash]
    def self.statistics_from_issues(essences, sprint_name)
      result = {
        'count' => essences.length,
        'timespent' => 0,
        'time_estimate' => 0,
        'added_during_sprint' => {
          'count' => 0,
          'timespent' => 0,
          'time_estimate' => 0,
          'time_original_estimate' => 0
        },
        'changes_during_sprint' => {
          'time_estimate' => 0,
          'time_original_estimate' => 0
        }
      }
      essences.each do |essence|
        result['time_estimate'] += essence['time_estimate'] || 0

        info = issue_sprint_information(essence, sprint_name)
        next if info.nil?

        if info['during_sprint']['added']
          result['added_during_sprint']['count'] += 1
          result['added_during_sprint']['timespent'] += info['timespent'] || 0
          result['added_during_sprint']['time_estimate'] += info['addition_to_sprint']['time_estimate'] || 0
          result['added_during_sprint']['time_original_estimate'] += info['addition_to_sprint']['time_original_estimate'] || 0
        end

        result['changes_during_sprint']['time_estimate'] += info['during_sprint']['time_estimate_change'] || 0
        result['changes_during_sprint']['time_original_estimate'] += info['during_sprint']['time_original_estimate_change'] || 0

        result['timespent'] += info['timespent'] || 0
        result['time_estimate'] += info['time_estimate'] || 0
      end

      result
    end
  end
end
