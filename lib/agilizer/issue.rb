require 'mongoid'

module Agilizer

  # Document to store Agilizer's issue data.
  #
  # Attributes:
  #   - identifier: string representing the identifier
  #     of the issue in its source application (e.g. the issue
  #     key in JIRA)
  #   - source: string representing the source of the issue
  #     (e.g. "jira")
  class Issue
    include Mongoid::Document

    store_in collection: 'agilizer_issues'

    # Identification
    field :identifier, type: String
    field :source, type: String
    field :project_key, type: String
    field :project_name, type: String

    # Dates
    field :created_at, type: Time
    field :updated_at, type: Time
    field :synced_at, type: Time
    field :deleted_at, type: Time
    field :resolved_at, type: Time

    # Estimate and worklogs
    field :timespent, type: Numeric
    field :time_original_estimate, type: Numeric
    field :time_estimate, type: Numeric

    # People
    field :assignee, type: String
    field :developer, type: String
    field :reviewer, type: String

    # Details
    field :summary, type: String
    field :description, type: String
    field :status, type: String
    field :type, type: String
    field :priority, type: String
    field :labels, type: Array
    field :category, type: String
    field :fix_versions, type: Array
    field :sprints, type: Array
    field :worklogs, type: Array
    field :bug_cause, type: String
    field :maintenance_type, type: String

    # Enrichments
    field :history, type: Array
    field :final_fix_version, type: String
    field :statuses_statistics, type: Hash
    field :time_per_status, type: Hash
    field :github_pull_requests, type: Array
    field :changed_files, type: Array
  end
end
