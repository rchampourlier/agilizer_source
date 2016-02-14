require 'rest-client'
require 'agilizer/issue'
require 'agilizer/interface/jira/transformations/3_add_sprint_information'

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

      def run(issue_identifier)
        issue = Issue.where(identifier: issue_identifier).first
        return if issue.nil?

        processing_data = issue.attributes
        sprint_names = sprint_names_from_history(processing_data)
        existing_sprint_names = processing_data['sprints'].map { |s| s['name'] }
        missing_sprint_names = sprint_names - existing_sprint_names

        enriched_sprints = missing_sprint_names.map do |sprint_name|
          sprint = all_sprints.find { |s| s['name'] == sprint_name }
          sprint_information = TRANSFORMATION.sprint_information(processing_data, sprint)
          sprint.merge sprint_information
        end

        processing_data.merge! 'sprints' => processing_data['sprints'] + enriched_sprints

        issue.attributes = processing_data
        issue.save!
        issue
      end
      module_function :run

      def sprint_names_from_history(processing_data)
        sprints_histories = HashOp::Filter.filter processing_data['history'], 'field' => 'sprints'
        sprints_histories.map do |h|
          [h['from'], h['to']]
        end.flatten
      end
      module_function :sprint_names_from_history

      # Returns the "sprint" Hash (name, started_at, ended_at, state)
      # for all sprints by fetching them from `Agilizer::Issue`
      # records.
      def all_sprints
        sprints = Agilizer::Issue.all.entries.map do |i|
          i['sprints']
        end
        sprints.flatten.map do |h|
          h.slice(*%w(name started_at ended_at state))
        end.uniq
      end
      module_function :all_sprints
    end
  end
end
