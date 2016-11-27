#!/usr/bin/env ruby
# frozen_string_literal: true

Sequel.migration do
  up do
    create_table :issues do

      # Identification
      String :identifier, primary_key: true
      String :source
      String :project_key
      String :project_name

      # Dates
      DateTime :created_at
      DateTime :updated_at
      DateTime :synced_at
      DateTime :deleted_at
      DateTime :resolved_at

      # Estimate and worklogs
      Fixnum :timespent
      Fixnum :time_original_estimate
      Fixnum :time_estimate

      # People
      String :assignee
      String :developer
      String :reviewer

      # Details
      String :summary, text: true
      String :description, text: true
      String :status
      String :type
      String :priority
      String :category
      String :bug_cause
      String :maintenance_type

      column :changed_files, "text[]"
      column :labels, "text[]"
      column :fix_versions, "json"
      column :history, "json"
      column :sprints, "json"
      column :statuses_statistics, "json"
      column :time_per_status, "json"
      column :worklogs, "json"

      # Enrichments
      column :final_fix_version, "json"
      column :github_pull_requests, "json"

      # Timestamps
      DateTime :local_created_at
      DateTime :local_updated_at
    end
  end

  down do
    drop_table(:issues)
  end
end
