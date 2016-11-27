# frozen_string_literal: true
require "spec_helper"
require "agilizer/data/issue_repository"
require "agilizer/enrichments/sprints_from_history"

describe Agilizer::Enrichments::SprintsFromHistory do

  describe ".run(issue_identifier)" do
    let(:issue_identifier) { "TP-3171" }
    let(:expected_sprint_name) { "Sprint 2015-12-08" }
    let(:expected_sprint_information) do
      {
        "started_at" => "2015-12-08 10:00:00 +0100",
        "addition_to_sprint" => {
          "time" => nil,
          "time_estimate" => nil,
          "time_original_estimate" => nil,
          "timespent" => nil,
          "status" => nil
        },
        "during_sprint" => {
          "added" => false,
          "removed" => false,
          "timespent_change" => 34_440,
          "time_estimate_change" => -34_440,
          "time_original_estimate_change" => 0
        },
        "name" => "Sprint 2015-12-08",
        "removal_from_sprint" => {
          "time" => nil,
          "time_estimate" => nil,
          "time_original_estimate" => nil,
          "timespent" => nil,
          "status" => nil
        },
        "sprint_end" => {
          "time_estimate" => 1_560,
          "time_original_estimate" => 36_000,
          "timespent" => 34_440, "status" => "Closed"
        },
        "sprint_start" => {
          "time_estimate" => 36_000,
          "time_original_estimate" => 36_000,
          "timespent" => nil,
          "status" => "Open"
        }
      }
    end

    let!(:enriched_issue) { SpecCase.load_issues(13).first }
    let!(:issue_with_missing_sprint_information) do
      attributes = {
        "identifier" => issue_identifier,
        "sprints" => [expected_sprint_information]
      }
      Agilizer::Data::IssueRepository.insert(attributes)
    end

    subject { described_class.run(issue_identifier) }

    it "enriches with information for the sprint missing them" do
      expected_sprint = subject["sprints"].find { |s| s["name"] == expected_sprint_name }
      expect(expected_sprint).to eq(expected_sprint_information)
    end
  end
end
