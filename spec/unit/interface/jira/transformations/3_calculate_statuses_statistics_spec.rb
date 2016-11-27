# frozen_string_literal: true
require "spec_helper"
require "timecop"
require "support/spec_case"
require "agilizer/interface/jira/transformations/1_basic_mapping"
require "agilizer/interface/jira/transformations/2_add_simple_history"
require "agilizer/interface/jira/transformations/2_set_worklog_time"
require "agilizer/interface/jira/transformations/3_calculate_statuses_statistics"

minute = 60
hour = 60 * minute

describe Agilizer::Interface::JIRA::Transformations::CalculateStatusesStatistics do

  let(:now) { Time.now }
  before { Timecop.freeze(now) }
  after { Timecop.return }

  let(:source_data) { SpecCase.get_jira_issues(1).first }
  let(:processed_data) do
    processing_data = Agilizer::Interface::JIRA::Transformations::BasicMapping.run(source_data, {})
    processing_data = Agilizer::Interface::JIRA::Transformations::AddSimpleHistory.run(source_data, processing_data)
    Agilizer::Interface::JIRA::Transformations::SetWorklogTime.run(source_data, processing_data)
  end

  describe "::run(source_data, processing_data)" do
    subject { described_class.run(source_data, processed_data) }

    it "should add the expected statistics" do
      statuses_statistics = subject["statuses_statistics"]
      expect(statuses_statistics).to eq(
        "development_started_at" => Time.parse("2014-07-30 15:58:55.352000000 +0200"),
        "review_started_at" => Time.parse("2014-08-29 15:15:03.827000000 +0200"),
        "functional_review_started_at" => Time.parse("2014-09-10 17:30:31.954000000 +0200"),
        "released_at" => Time.parse("2014-10-24 14:29:23.810000000 +0200"),
        "closed_at" => nil,
        "returns_from_review" => 6,
        "returns_from_functional_review" => 1
      )
    end

    context "no returns from review or functional review" do
      let(:source_data) { SpecCase.get_jira_issues(2).first }

      it "sets \"returns_from_...\" to 0" do
        statuses_statistics = subject["statuses_statistics"]
        expect(statuses_statistics["returns_from_review"]).to eq(0)
        expect(statuses_statistics["returns_from_functional_review"]).to eq(0)
      end
    end
  end

  describe "implementation" do
    let(:history) { {} }
    let(:time_1) { now - 1 * hour }
    let(:time_2) { now - 1 * minute }

    describe "::calculate_statuses_moments(history)" do
      subject { described_class.calculate_statuses_moments(history) }

      it "returns empty statistics" do
        expect(subject).to eq(
          "development_started_at" => nil,
          "review_started_at" => nil,
          "functional_review_started_at" => nil,
          "released_at" => nil,
          "closed_at" => nil
        )
      end

      context "with a single development start" do
        let(:history) do
          [{
            "field" => "status",
            "from" => "Open",
            "to" => "In Development",
            "time" => time_1
          }]
        end

        it "sets \"development_started_at\" to the expected value" do
          expect(subject["development_started_at"]).to eq(time_1)
        end
      end

      context "with multiple review starts" do
        let(:history) do
          [{
            "field" => "status",
            "from" => "In Development",
            "to" => "In Review",
            "time" => time_1
          }, {
            "field" => "status",
            "from" => "In Development",
            "to" => "In Review",
            "time" => time_2
          }]
        end

        it "sets \"review_started_at\" to the first one" do
          expect(subject["review_started_at"]).to eq(time_1)
        end
      end

      context "with multiple changes to \"Released\"" do
        let(:history) do
          [{
            "field" => "status",
            "from" => "In Development",
            "to" => "Released",
            "time" => time_1
          }, {
            "field" => "status",
            "from" => "In Functional Review",
            "to" => "Released",
            "time" => time_2
          }]
        end
        it "sets \"released_at\" to the last time" do
          expect(subject["released_at"]).to eq(time_2)
        end
      end
    end

    describe "::calculate_statuses_returns(history)" do
      subject { described_class.calculate_statuses_returns(history) }

      it "returns empty statistics" do
        expect(subject).to eq(
          "returns_from_review" => 0,
          "returns_from_functional_review" => 0
        )
      end

      context "multiple returns from review" do
        let(:history) do
          [{
            "field" => "status",
            "from" => "In Review",
            "to" => "Open",
            "time" => time_1
          }, {
            "field" => "status",
            "from" => "In Review",
            "to" => "In Development",
            "time" => time_2
          }]
        end

        it "returns 2 for \"returns_from_review\"" do
          expect(subject["returns_from_review"]).to eq(2)
        end
      end
    end
  end
end
