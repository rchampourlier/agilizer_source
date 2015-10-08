require 'agilizer/issue'

module Agilizer

  # The UpdateManager handles an issue update from any source.
  # For example, an importer may receive a new issue (through sync
  # or event), transform the source issue data into Agilizer's,
  # and then use `UpdateManager.run(data)`.
  #
  # The UpdateManager will then persist the issue data as appropriate
  # (in a new issue, or update the existing one), and notify possible
  # subscribers of the update.
  module UpdateManager

    def run(data)
      issue = find_issue(data) || new_issue
      issue.attributes = data
      issue.save
    end
    module_function :run

    # Returns the issue for the specified data, based on the data
    # identifier and source values.
    # Fails if several issues are found matching these criteria.
    def find_issue(data)
      issues = Issue.where(
        identifier: data['identifier'],
        source: data['source']
      )
      if issues.count > 1
        fail "Found multiple issues for identifier \"#{data['identifier']}\" and source \"#{data['source']}\""
      end
      return nil if issues.count == 0
      issues.first
    end
    module_function :find_issue

    def new_issue
      Issue.new
    end
    module_function :new_issue
  end
end
