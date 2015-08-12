require 'spec_helper'
require 'support/spec_case'
require 'agilizer/interface/jira/transformations/1_basic_mapping'
require 'agilizer/interface/jira/transformations/2_add_simple_history'
require 'agilizer/interface/jira/transformations/2_set_worklog_time'
require 'agilizer/interface/jira/transformations/3_add_status_to_worklogs'
require 'agilizer/interface/jira/transformations/4_add_timespent_per_status_per_author'

describe Agilizer::Interface::Jira::Transformations::AddTimespentPerStatusPerAuthor do
  let(:source_data) { SpecCase.get_jira_issues(1).first }
  let(:processing_data) do
    data = Agilizer::Interface::Jira::Transformations::BasicMapping.run(source_data, {})
    data = Agilizer::Interface::Jira::Transformations::AddSimpleHistory.run(source_data, data)
    data = Agilizer::Interface::Jira::Transformations::SetWorklogTime.run(source_data, data)
    Agilizer::Interface::Jira::Transformations::AddStatusToWorklogs.run(source_data, data)
  end

  describe '::run(source_data, processing_data)' do
    subject { described_class.run(source_data, processing_data) }

    context 'processing_data has no worklogs' do
      before { processing_data['worklogs'] = [] }

      it 'adds "timespent_per_status" with nil value' do
        expect(subject.keys).to include('timespent_per_status_per_author')
        expect(subject['timespent_per_status_per_author']).to eq(nil)
      end
    end

    it 'adds the expected timespent for each status' do
      expect(subject['timespent_per_status_per_author']).to eq([
        {
          'author' => 'team.member.1',
          'timespent' => [
            { 'status' => 'In Development', 'timespent' => 129_600 },
            { 'status' => 'In Review', 'timespent' => 4_800 }
          ]
        },
        { 'author' => 'team.member.6', 'timespent' => [{ 'status' => 'In Review', 'timespent' => 2_700 }] },
        { 'author' => 'team.member.5', 'timespent' => [{ 'status' => 'In Review', 'timespent' => 4_200 }] },
        { 'author' => 'team.member.7', 'timespent' => [
          { 'status' => 'In Functional Review', 'timespent' => 9_000 },
          { 'status' => 'In Review', 'timespent' => 43_620 },
          { 'status' => 'In Development', 'timespent' => 2_400 },
          { 'status' => 'Ready for Release', 'timespent' => 60 }
        ]}
      ])
    end
  end
end
