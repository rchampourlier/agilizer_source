# frozen_string_literal: true
require "spec_helper"
require "agilizer/interface/jira/notifier"

describe Agilizer::Interface::JIRA::Notifier do
  let(:event_data) { { key: "issue_key", data: issue_data } }
  let(:issue_data) { { source: true } }
  let(:processed_data) { { processed: true } }

  before do
    allow(Agilizer::Data::IssueRepository)
      .to receive(:insert)
      .and_return(nil)
  end

  after do
    allow(Agilizer::Data::IssueRepository)
      .to receive(:insert)
      .and_call_original
    RSpec::Mocks.space.proxy_for(Agilizer::Interface::JIRA::Transformations).reset
  end

  describe "#publish(event_name, data)" do
    let(:subject) { described_class.new }

    context "event name is \"fetched_issue\"" do
      let(:event_name) { :fetched_issue }

      it "processes the issue data with Transformations::run(data)" do
        expect(Agilizer::Interface::JIRA::Transformations)
          .to receive(:run)
          .with(issue_data)
        subject.publish(event_name, event_data)
      end

      it "runs Data::IssueRepository.run(processed_data)" do
        allow(Agilizer::Interface::JIRA::Transformations)
          .to receive(:run)
          .with(issue_data)
          .and_return(processed_data)
        expect(Agilizer::Data::IssueRepository)
          .to receive(:insert)
          .with(processed_data)
        subject.publish(event_name, event_data)
      end
    end

    context "unknown event name" do
      let(:event_name) { :unknown }

      it "raises an Error" do
        expect do
          subject.publish(event_name, event_data)
        end.to raise_error(StandardError, "Unknown event \"unknown\"")
      end
    end
  end
end
