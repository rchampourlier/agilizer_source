require 'data/issue_document'

module Agilizer

  # Search within `Data::IssueDocument`s.
  module Search

    # @return [Array] array of Data::IssueDocument::Datum contents for
    #   issues with a change on the "Sprint" field
    def data_with_sprint_change
      history_field_query = { :field => 'Sprint' }
      history_query = { :items => { :$elemMatch => history_field_query } }
      Data::IssueDocument.where(:'data.changelog.histories' => { :$elemMatch => history_query }).map(&:content)
    end
    module_function :data_with_sprint_change

    # @return [Array] Data::IssueDocument essences with only 'essence.updated_at' and
    #   'essence.sprints' loaded.
    def sprints_by_essence_updated_at
      issues = Data::IssueDocument.only('data.updated_at', 'data.sprints').where('data.sprints.1' => { :$exists => true })
      issues.inject({}) do |hash, issue|
        hash[issue['essence.updated_at']] = issue['essence.sprints']
        hash
      end
    end
    module_function :sprints_by_essence_updated_at

    # @param sprint_name [String]
    # @return [Array] an array of Data::IssueDocument essence attributes
    #   associated to the specified sprint
    def essences_for_sprint(sprint_name)
      print "[DEPRECATED] replace by ::essences_with_filter"
      item_query = { :$elemMatch => { :'name' => sprint_name } }
      essences_with_query :'essence.sprints' => item_query
    end
    module_function :essences_for_sprint

    # @param [Date, Time] from
    # @param [Date, Time] to
    # @return [Array] an array of Data::IssueDocument essence attributes
    #   matching the specified dates
    def essences_updated_between(from, to)
      Data::IssueDocument.where(
        :'essence.updated_at'.gt => from.to_time,
        :'essence.updated_at'.lt => to.to_time
      ).map(&:essence)
    end
    module_function :essences_updated_between

    # @param [Date, Time] from
    # @param [Date, Time] to
    # @return [Array] an array of Data::IssueDocument essence for issues with
    #   at least 1 worklog whose "time" is between from and
    #   to.
    def issues_with_worklogs_between(from, to)
      worklog_query = { time: { :$gt => from.to_time, :$lt => to.to_time } }
      issue_query = { :'essence.worklogs' => { :$elemMatch => worklog_query } }
      Data::IssueDocument.where(issue_query).map(&:essence)
    end
    module_function :issues_with_worklogs_between

    # @param [Date, Time] from
    # @param [Date, Time] to
    # @return [Array] an array of worklog hashes matching
    #   the specified dates (same format as within
    #   essence['worklogs'])
    def worklogs_between(from, to)
      essences = issues_with_worklogs_between(from, to)
      worklogs = essences.map { |e| Process::Worklog.rich_worklogs(e) }.flatten
      Process::Worklog.filter_between(worklogs, from, to)
    end
    module_function :worklogs_between
  end
end
