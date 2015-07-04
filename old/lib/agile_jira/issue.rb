require 'config/mapping'

module Agilizer

  # Model for the Agilizer internal issue representation.
  #
  # Issues from varied sources (currently only JIRA - through
  # JiraCache) are converted to this model's format.
  #
  class Issue
    include Mongoid::Document
    include Mongoid::Timestamps

    store_in collection: 'agilizer.issues'

    # Generating fields according to the mapping
    MAPPING.each do |field_key, field_info|
      field_type = field_info[:type] || :string
      field field_key.to_sym, type: field_type
    end

    def self.find_by_key(issue_key)
      where(key: issue_key).first
    end

    # Creates or updates an `IssueDocument` with
    # the specified attributes.
    #
    # If the `key` attributes matches an existing
    # document, this document is updated. Otherwise,
    # a new document is created.
    def self.create_or_update(attributes)
      key = attributes['key']
      issue = find_by_key(key)
      issue ||= self.new
      issue.attributes = attributes
      issue.save!
      issue
    end
  end
end
