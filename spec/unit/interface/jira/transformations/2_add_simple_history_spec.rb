require "spec_helper"
require "support/spec_case"
require "agilizer/interface/jira/transformations/2_add_simple_history"

describe Agilizer::Interface::JIRA::Transformations::AddSimpleHistory do

  describe "::run(source_data, processing_data)" do

    before(:all) do
      @source_data = SpecCase.get_jira_issues(3).first
      @result = described_class.run(@source_data, {})["history"]
    end

    it "only contains supported histories" do
      fields = @result.map { |r| r["field"] }.uniq.sort
      expect(fields).to eq %w(
        assignee
        status
        time_estimate
        time_original_estimate
      )
    end

    describe "flattening history items" do
      it "includes the time of the containing history" do
        first_result = @result.first
        histories = HashOp::Deep.fetch @source_data, "changelog.histories"
        history_for_first_result = histories.find do |history|
          original_field =
            case first_result["field"]
            when "time_estimate" then "timeestimate"
            when "time_original_estimate" then "timeoriginalestimate"
            else first_result["field"]
            end
          history["items"].find { |i| i["field"] == original_field }
        end
        history_time = history_for_first_result["created"]
        expect(first_result["time"]).to eq(Time.parse(history_time))
      end
    end

    describe "on field \"timeestimate\"" do
      it "should parse the values to an integer" do
        history = @result.find { |h| h["field"] == "time_estimate" }
        from = history["from"]
        to = history["to"]
        expect(from.nil? || from.is_a?(Numeric)).to be true
        expect(to.nil? || to.is_a?(Numeric)).to be true
      end
    end

    describe "on field \"timeoriginalestimate\"" do
      it "should parse the values to integers" do
        history = @result.find { |h| h["field"] == "time_original_estimate" }
        from = history["from"]
        to = history["to"]
        expect(from.nil? || from.is_a?(Numeric)).to be true
        expect(to.nil? || to.is_a?(Numeric)).to be true
      end
    end
  end
end
