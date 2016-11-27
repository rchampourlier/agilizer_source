# frozen_string_literal: true
require "spec_helper"
require "support/spec_case"
require "agilizer/interface/jira/transformations/1_basic_mapping"
require "agilizer/interface/jira/transformations/2_add_simple_history"
require "agilizer/interface/jira/transformations/2_set_worklog_time"
require "agilizer/interface/jira/transformations/support/timespent_at_time"

hour = 60 * 60

describe Agilizer::Interface::Jira::Transformations::Support do

  describe "::timespent_at_time(data, time)" do

    let(:data) do
      source_data = SpecCase.get_jira_issues(1).first
      processing_data = Agilizer::Interface::Jira::Transformations::BasicMapping.run(source_data, {})
      processing_data = Agilizer::Interface::Jira::Transformations::SetWorklogTime.run(source_data, processing_data)
      Agilizer::Interface::Jira::Transformations::AddSimpleHistory.run(source_data, processing_data)
    end

    context "before issue creation" do
      let(:time) { data["created_at"] - 1 * hour }

      it "should be nil" do
        result = described_class.timespent_at_time(data, time)
        expect(result).to eq(nil)
      end
    end

    context "now" do
      let(:time) { Time.now }

      it "should be equal to the total timespent" do
        result = described_class.timespent_at_time(data, time)
        expect(result).to eq(data["timespent"])
      end
    end
  end
end
