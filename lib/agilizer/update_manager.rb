# frozen_string_literal: true

module Agilizer

  # The UpdateManager handles an issue update from any source.
  # For example, an importer may receive a new issue (through sync
  # or event), transform the source issue data into Agilizer's,
  # and then use `UpdateManager.run(data)`.
  #
  # The UpdateManager will then persist the issue data as appropriate
  # (in a new issue, or update the existing one).
  class UpdateManager
    class << self

      def run(data)
        if find_issue(data)
          identifier = data[:identifier]
          Data::IssueRepository.update_where({ identifier: identifier }, data)
        else
          Data::IssueRepository.insert(data)
        end
      end

      def find_issue(data)
        Data::IssueRepository.find_by(identifier: data[:identifier])
      end
    end
  end
end
