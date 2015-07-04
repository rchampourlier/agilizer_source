require 'spec_helper'
require 'support/spec_case'
require 'agilizer/interface/jira/transformations/1_basic_mapping'
require 'agilizer/interface/jira/transformations/2_add_simple_history'
require 'agilizer/interface/jira/transformations/2_set_worklog_time'
require 'agilizer/interface/jira/transformations/3_add_sprint_name_to_worklogs'

describe Agilizer::Interface::Jira::Transformations::AddSprintNameToWorklogs do
  let(:source_data) { SpecCase.get_jira_issues(1).first }
  let(:processing_data) do
    processing_data = Agilizer::Interface::Jira::Transformations::BasicMapping.run(source_data, {})
    processing_data = Agilizer::Interface::Jira::Transformations::AddSimpleHistory.run(source_data, processing_data)
    Agilizer::Interface::Jira::Transformations::SetWorklogTime.run(source_data, processing_data)
  end

  describe '::run(source_data, processing_data)' do

    it 'should add the expected status' do
      result = described_class.run(source_data, processing_data)
      expect(result['worklogs'].first['sprint_name']).to eq('Sprint 2014-08-18')
    end
  end
end
