# frozen_string_literal: true
require "spec_helper"
require "timecop"
require "agilizer/interface/jira/transformations/2_set_worklog_time"

minute = 60
hour = 60 * minute

describe Agilizer::Interface::Jira::Transformations::SetWorklogTime do
  let(:time) { Time.now }
  before { Timecop.freeze(time) }
  after { Timecop.return }

  describe "::run(_source_data, processing_data)" do
    let(:processing_data) do
      {
        "worklogs" => [
          {
            "created_at" => created_at,
            "started_at" => started_at,
            "timespent" => timespent
          }
        ]
      }
    end

    subject do
      described_class.run(nil, processing_data)["worklogs"].first["time"]
    end

    context "started_at before created_at" do
      let(:started_at) { time }
      let(:created_at) { time + 1 * hour }
      let(:timespent) { 0 }

      it "set time to started_at" do
        expect(subject).to eq(time)
      end
    end

    context "created_at before started_at" do
      let(:started_at) { time }
      let(:created_at) { time - 1 * hour }
      let(:timespent) { 1 * hour }

      it "set time to created_at - timespent" do
        expect(subject).to eq(time - 2 * hour)
      end

      context "timespent is nil" do
        let(:timespent) { nil }
        it "considers timespent equal to 0" do
          expect(subject).to eq(time - 1 * hour)
        end
      end
    end
  end
end
