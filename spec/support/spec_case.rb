require 'agilizer/interface/jira/notifier'

# Loader for JIRA issue fixtures
class SpecCase

  def self.get_jira_issues(*indices)
    indices.map do |index|
      file = File.expand_path("spec/fixtures/jira_issues/case_#{index}.json")
      JSON.parse File.read(file)
    end
  end

  # Load the spec cases for the specified indices
  # in the local database as `Agilizer::Issue` records.
  def self.load_issues(*indices)
    jira_issues = get_jira_issues(*indices)
    jira_issues.each do |jira_issue|
      event = {
        key: jira_issue['key'],
        data: jira_issue
      }
      logger = ::Logger.new(File.open('/dev/null', 'w'))
      notifier = Agilizer::Interface::Jira::Notifier.new(logger: logger)
      notifier.publish :fetched_issue, event
    end
  end
end
