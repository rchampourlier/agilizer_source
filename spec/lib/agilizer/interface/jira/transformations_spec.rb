require 'spec_helper'
require 'support/spec_case'
require 'agilizer/interface/jira/transformations'

describe Agilizer::Interface::Jira::Transformations do
  let(:transformation_1_addition) { { gone_through_1: true } }
  let(:transformation_2_addition) { { gone_through_2: true } }

  # Example transformation module
  module Transformation1
    def run(source_data, _processing_data)
      source_data.merge(gone_through_1: true)
    end
    module_function :run
  end

  # Example transformation module
  module Transformation2
    def run(_source_data, processing_data)
      processing_data.merge(gone_through_2: true)
    end
    module_function :run
  end

  describe '::run(data)' do
    subject { described_class }
    let(:source_data) { { source_data: true } }

    before do
      allow(described_class)
        .to receive(:transformations)
        .and_return([[Transformation1], [Transformation2]])
    end

    it 'applies all transformations in order' do
      expect(Transformation1)
        .to receive(:run)
        .ordered
        .with(source_data, nil)
        .and_return(gone_through_1: true)
      expect(Transformation2)
        .to receive(:run)
        .ordered
        .with(source_data, gone_through_1: true)
        .and_return(gone_through_both: true)
      result = subject.run(source_data)
      expect(result).to eq(gone_through_both: true)
    end
  end

  describe '::transformations' do

    # This spec would probably be better with stubbed transformation module
    # files. This would allow adding new transformations without breaking
    # this spec.
    it 'returns grouped transformation modules' do
      expect(described_class.transformations).to eq([
        [
          Agilizer::Interface::Jira::Transformations::BasicMapping
        ],
        [
          Agilizer::Interface::Jira::Transformations::AddSimpleHistory,
          Agilizer::Interface::Jira::Transformations::ExtractGithubPullRequestsFromComments,
          Agilizer::Interface::Jira::Transformations::SetWorklogTime
        ],
        [
          Agilizer::Interface::Jira::Transformations::AddFinalFixVersion,
          Agilizer::Interface::Jira::Transformations::AddSprintInformation,
          Agilizer::Interface::Jira::Transformations::AddSprintNameToWorklogs,
          Agilizer::Interface::Jira::Transformations::AddStatusToWorklogs
        ]
      ])
    end
  end
end
