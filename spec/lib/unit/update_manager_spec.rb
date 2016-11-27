# frozen_string_literal: true
require "spec_helper"
require "timecop"
require "agilizer/update_manager"
require "agilizer/data/issue_repository"

day = 60 * 60 * 24
week = 7 * day
month = 30 * day
year = 365.25 * day

describe Agilizer::UpdateManager do
  subject { described_class }
  let(:now) { Time.now }
  before { Timecop.freeze(now) }
  after { Timecop.return }

  describe "::run(data)" do
    let(:identifier) { "identifier" }
    let(:source) { "source" }
    let(:created_at) { now - 1 * month }
    let(:updated_at) { now - 1 * week }
    let(:data) do
      {
        identifier: identifier,
        source: source,
        created_at: created_at,
        updated_at: updated_at
      }
    end

    context "new issue" do
      before do
        expect(
          Agilizer::Data::IssueRepository.count
        ).to eq(0)
      end

      it "saves the data in a new issue" do
        expect { subject.run(data) }
          .to change { Agilizer::Data::IssueRepository.count }
          .by(1)
        issue = Agilizer::Data::IssueRepository.last
        expect(issue[:identifier]).to eq(identifier)
        expect(issue[:updated_at]).to be_within(1).of(updated_at)
        expect(issue[:local_created_at]).to be_within(1).of(now)
      end
    end

    context "existing issue" do

      let(:existing_data) do
        {
          "identifier" => identifier,
          "source" => source,
          "created_at" => now - 1 * year,
          "updated_at" => now - 1 * year,
          "time_original_estimate" => 10_000
        }
      end

      before do
        Agilizer::Data::IssueRepository.insert(existing_data)
      end

      it "updates the existing record with the new data" do
        subject.run(data)
        issue = Agilizer::Data::IssueRepository.find_by(identifier: identifier)
        expect(issue["created_at"]).to be_within(1).of(created_at)
      end

      it "doesn't overwrite fields not present in the new data" do
        subject.run(data)
        issue = Agilizer::Data::IssueRepository.find_by(identifier: identifier)
        expect(issue["time_original_estimate"]).to eq(existing_data["time_original_estimate"])
      end
    end
  end
end
