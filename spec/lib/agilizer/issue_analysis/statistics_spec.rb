require 'spec_helper'
require 'agilizer/interface/jira/transformations'
require 'agilizer/issue_analysis/statistics'

describe Agilizer::IssueAnalysis::Statistics do
  let(:issues) do
    SpecCase.load_issues(*spec_case_indices)
    Agilizer::Issue.all.entries
  end

  describe '::sprint_data(issues, sprint_name, issue_grouping_path, sprint_data_groups, value_path)' do

    let(:spec_case_indices) { (11..12) }
    let(:sprint_name) { 'Sprint 2015-09-03' }
    let(:issue_grouping_path) { 'developer' }
    let(:sprint_data_groups) { %w(sprint_start sprint_end) }
    let(:value_path) { 'time_estimate' }

    subject { described_class.sprint_data(issues, sprint_name, issue_grouping_path, sprint_data_groups, value_path) }

    it 'returns the expected result' do
      expected_result = [
        {
          'developer' => 'team.member.8',
          'now' => 0,
          'sprint_end' => 0,
          'sprint_start' => 28_800
        },
        {
          'developer' => 'team.member.5',
          'now' => 0,
          'sprint_end' => 0,
          'sprint_start' => 50_400
        }
      ]
      expect(subject).to eq(expected_result)
    end
  end

  describe '::timespent(issues, sprint_name, grouping_attributes)' do
    let(:spec_case_indices) { (11..12) }
    let(:sprint_name) { 'Sprint 2015-09-03' }

    subject { described_class.timespent(issues, sprint_name, grouping_attributes) }

    context 'grouping on author' do
      let(:grouping_attributes) { %w(author) }
      it 'returns the expected data' do
        expect(subject).to eq([
          {
            'author' => 'team.member.8',
            'timespent' => 28_860
          },
          {
            'author' => 'team.member.10',
            'timespent' => 37_740
          }
        ])
      end
    end

    context 'grouping on author and status' do
      let(:grouping_attributes) { %w(author status) }
      it 'returns the expected data' do
        expect(subject).to eq([
          {
            'author' => 'team.member.8',
            'status' => 'Open',
            'timespent' => 5340
          },
          {
            'author' => 'team.member.8',
            'status' => 'In Development',
            'timespent' => 23_520
          },
          {
            'author' => 'team.member.10',
            'status' => 'In Development',
            'timespent' => 33_420
          },
          {
            'author' => 'team.member.10',
            'status' => 'In Review',
            'timespent' => 4_320
          }
        ])
      end
    end
  end
end
