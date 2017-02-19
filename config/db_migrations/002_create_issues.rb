#!/usr/bin/env ruby
# frozen_string_literal: true

Sequel.migration do
  up do
    create_table :issues do

      # Metadata
      String :source
      DateTime :synced_at
      DateTime :deleted_at
      DateTime :local_created_at
      DateTime :local_updated_at

      # Fields from mapping
      String :identifier, primary_key: true
      DateTime :created_at
      DateTime :updated_at
      String :project_name
      String :project_key
      String :status
      DateTime :resolved_at
      String :priority
      String :summary, text: true
      String :description, text: true
      String :type
      Fixnum :timespent
      Fixnum :time_original_estimate
      Fixnum :time_estimate
      column :labels, "text[]"
      column :components, "text[]"
      String :category
      String :assignee
      String :developer_backend
      String :developer_frontend
      String :reviewer
      String :product_owner
      String :bug_cause
      String :epic
      String :tribe

      # Calculated
      column :changed_files, "text[]"
      column :fix_versions, "json"
      column :history, "json"
      column :statuses_statistics, "json"
      column :time_per_status, "json"
      column :worklogs, "json"

      # Enrichments
      String :final_fix_version
      column :github_pull_requests, "json"
    end
  end

  down do
    drop_table(:issues)
  end
end
