require 'spec_helper'
require 'support/spec_case'
require 'agilizer/interface/jira/transformations/1_basic_mapping'
require 'agilizer/interface/jira/transformations/2_add_simple_history'
require 'agilizer/interface/jira/transformations/2_set_worklog_time'
require 'agilizer/interface/jira/transformations/3_add_status_to_worklogs'

describe Agilizer::Interface::JIRA::Transformations::AddStatusToWorklogs do
  let(:source_data) { SpecCase.get_jira_issues(1).first }
  let(:processed_data) do
    processing_data = Agilizer::Interface::JIRA::Transformations::BasicMapping.run(source_data, {})
    processing_data = Agilizer::Interface::JIRA::Transformations::AddSimpleHistory.run(source_data, processing_data)
    Agilizer::Interface::JIRA::Transformations::SetWorklogTime.run(source_data, processing_data)
  end

  describe '::run(source_data, processing_data)' do

    it 'should add the expected status' do
      result = described_class.run(source_data, processed_data)
      expect(result['worklogs'].first['status']).to eq('In Development')
    end
  end
end
