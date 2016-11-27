# frozen_string_literal: true
require "agilizer/interface/jira/notifier"

# Loader for JIRA issue fixtures
class SpecCase

  # Read the spec cases fixture files for the specified indices
  # and return an array of hashes representing the JIRA issues.
  def self.get_jira_issues(*indices)
    indices.map do |index|
      file = File.expand_path("spec/fixtures/jira_issues/case_#{index}.json")
      JSON.parse File.read(file)
    end
  end

  # Load the spec cases for the specified indices and create the
  # corresponding "Issue" records in the local database.
  def self.load_issues(*indices)
    jira_issues = get_jira_issues(*indices)
    jira_issues.each do |jira_issue|
      event = {
        key: jira_issue["key"],
        data: jira_issue
      }
      logger = ::Logger.new(File.open("/dev/null", "w"))
      notifier = Agilizer::Interface::Jira::Notifier.new(logger: logger)
      notifier.publish :fetched_issue, event
    end
  end
end
