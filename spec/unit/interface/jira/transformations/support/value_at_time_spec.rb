# frozen_string_literal: true
require "spec_helper"
require "timecop"
require "support/spec_case"
require "agilizer"
require "agilizer/interface/jira/transformations/support/value_at_time"
require "agilizer/interface/jira/transformations/2_add_simple_history"

second = 1

describe Agilizer::Interface::JIRA::Transformations::Support do

  let(:source_data) { SpecCase.get_jira_issues(1).first }
  let(:time) { Time.now }
  let(:field) { "assignee" }

  before { Timecop.freeze(time) }
  after { Timecop.return }

  describe "::value_at_time(processing_data, field, time)" do
    let(:processing_data) { {} }

    context "processing_data not enriched with history" do
      it "should raise an error" do
        expect do
          described_class.value_at_time(processing_data, field, time)
        end.to raise_error(Agilizer::Error, "Processing data must have been processed by `AddSimpleHistory`")
      end
    end

    context "field is not authorized" do
      let(:field) { "field" }
      it "raises an error" do
        expect do
          described_class.value_at_time(processing_data, field, time)
        end.to raise_error(Agilizer::Error, /Invalid field/)
      end
    end

    context "when there is no history" do
      let(:processing_data) do
        {
          "assignee" => "current field value",
          "history" => []
        }
      end

      it "should return the current value" do
        result = described_class.value_at_time(processing_data, field, time)
        expect(result).to eq("current field value")
      end
    end

    context "with at least one history before the time" do

      let(:processing_data) do
        {
          "history" => [
            {
              "field" => field,
              "time" => (time - 1 * second),
              "from" => 1,
              "to" => 2
            }
          ]
        }
      end

      it "should return the \"to\" value of this history" do
        result = described_class.value_at_time(processing_data, field, time)
        expect(result).to eq 2
      end
    end

    context "with no history before the time, at least one after" do

      let(:processing_data) do
        {
          "history" => [
            {
              "field" => field,
              "time" => (time + 1 * second),
              "from" => 1,
              "to" => 2
            }
          ]
        }
      end

      it "should return the \"from\" value of this history" do
        result = described_class.value_at_time(processing_data, field, time)
        expect(result).to eq 1
      end
    end

    context "spec data 1" do
      let(:processing_data) do
        Agilizer::Interface::JIRA::Transformations::AddSimpleHistory.run(source_data, {})
      end
      subject { described_class.value_at_time(processing_data, field, time) }

      context "sprint \"Sprint 2014-10-13\"" do
        let(:sprint) { "Sprint 2014-10-13" }

        context "time_original_estimate" do
          let(:field) { "time_original_estimate" }

          context "at 2014-10-13 13:35:00 +0200" do
            let(:time) { Time.parse "2014-10-13 13:35:00 +0200" }

            it { should eq(14_400) }
          end
        end
      end
    end
  end
end
