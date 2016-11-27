# frozen_string_literal: true
require "hash_op"
require "rest-client"
require "agilizer/interface/jira/transformations/3_add_sprint_information"
require "agilizer/data/issue_repository"

module Agilizer
  module Enrichments

    # Enriches issues by extracting information on sprints which
    # are not present in the "sprints" field but present in the
    # history of the issue.
    #
    # This happens when an issue is removed of a sprint before
    # the sprint is closed. Since the issue may have been worked
    # on during the sprint, we want to "rebuild" this sprint
    # information and add it to the issue.
    #
    # To do it, we fetch all sprints by looking at the history,
    # and if we find one not present in the issues "sprints"
    # attributes, we rebuild it using sprint information from
    # the existing issues.
    module SprintsFromHistory
      TRANSFORMATION = Interface::Jira::Transformations::AddSprintInformation

      def run(issue_identifier, sprints_info = nil)
        data = Data::IssueRepository.find_by(identifier: issue_identifier)
        return if data.nil?

        sprint_names = sprint_names_from_history(data)
        existing_sprint_names = data["sprints"].compact.map { |s| s["name"] }
        missing_sprint_names = (sprint_names - existing_sprint_names).compact # TODO: cover with spec on JT-214

        sprints_info ||= build_sprints_info
        enriched_sprints = missing_sprint_names.map do |sprint_name|
          sprint = sprints_info.find { |s| s["name"] == sprint_name }
          next if sprint.nil? || sprint.empty? # TODO: cover with spec on JT-2461
          sprint_information = TRANSFORMATION.sprint_information(data, sprint)
          sprint.merge sprint_information
        end

        data["sprints"] = (data["sprints"] + enriched_sprints).compact
        Data::IssueRepository.insert(data)
        data
      end
      module_function :run

      def sprint_names_from_history(data)
        sprints_histories = HashOp::Filter.filter data["history"], "field" => "sprints"
        sprints_histories.map do |h|
          [h["from"], h["to"]]
        end.flatten
      end
      module_function :sprint_names_from_history

      # Returns the "sprint" Hash (name, started_at, ended_at, state)
      # for all sprints by fetching them from "Issue"
      # records.
      def build_sprints_info
        sprints = Agilizer::Data::IssueRepository.index.map do |i|
          i["sprints"]
        end
        sprints.flatten.compact.map do |h|
          h.slice(*%w(name started_at ended_at state))
        end.uniq
      end
      module_function :build_sprints_info
    end
  end
end
