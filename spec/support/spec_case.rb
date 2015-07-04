# Loader for JIRA issue fixtures
class SpecCase

  def self.get_jira_issues(*indices)
    indices.map do |index|
      file = File.expand_path("spec/fixtures/jira_issues/case_#{index}.json")
      JSON.parse File.read(file)
    end
  end
end
