require "spec_helper"
require "agilizer/interface/jira/notifier"

describe Agilizer::Interface::Jira::Notifier do
  let(:event_data) { { key: "issue_key", data: issue_data } }
  let(:issue_data) { { source: true } }
  let(:processed_data) { { processed: true } }

  describe "#publish(event_name, data)" do
    let(:subject) { described_class.new }
    let(:processor) { double("Processor") }

    before do
      allow(Agilizer::Data::IssueRepository)
        .to receive(:insert)
        .and_return(nil)
    end

    context "event name is \"fetched_issue\"" do
      let(:event_name) { "fetched_issue" }

      it "processes the issue data with Transformations::run(data)" do
        expect(Agilizer::Interface::Jira::Transformations)
          .to receive(:run)
          .with(issue_data)
        subject.publish(event_name, event_data)
      end

      it "runs Data::IssueRepository.run(processed_data)" do
        allow(Agilizer::Interface::Jira::Transformations)
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
      let(:event_name) { "unknown" }

      it "fails with no method error" do
        expect do
          subject.publish(event_name, event_data)
        end.to raise_error(NoMethodError)
      end
    end
  end
end
