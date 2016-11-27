require 'spec_helper'
require 'support/spec_case'
require 'agilizer/interface/jira/transformations/1_basic_mapping'
require 'agilizer/interface/jira/transformations/2_add_simple_history'
require 'agilizer/interface/jira/transformations/2_set_worklog_time'
require 'agilizer/interface/jira/transformations/3_add_sprint_information'

describe Agilizer::Interface::JIRA::Transformations::AddSprintInformation do

  let(:source_data) { SpecCase.get_jira_issues(1).first }
  let(:processing_data) do
    processing_data = Agilizer::Interface::JIRA::Transformations::BasicMapping.run(source_data, {})
    processing_data = Agilizer::Interface::JIRA::Transformations::SetWorklogTime.run(source_data, processing_data)
    Agilizer::Interface::JIRA::Transformations::AddSimpleHistory.run(source_data, processing_data)
  end

  describe '::run(source_data, processing_data)' do

    context 'common case (spec 1)' do
      let(:source_data) { SpecCase.get_jira_issues(1).first }
      let(:expected_sprint_name) { 'Sprint 2014-10-13' }
      let(:expected_sprint_information) do
        {
          'name' => expected_sprint_name,
          'started_at' => Time.parse('2014-10-13 13:35:00.000000000 +0200'),
          'ended_at' => Time.parse('2014-10-24 19:00:00.000000000 +0200'),
          'state' => 'CLOSED',
          'during_sprint' => {
            'added' => false,
            'removed' => false,
            'timespent_change' => 94_380,
            'time_estimate_change' => -14_400,
            'time_original_estimate_change' => 0
          },
          'addition_to_sprint' => {
            'time' => Time.parse('2014-10-11T09:27:42.876+0200'),
            'time_estimate' => 0,
            'time_original_estimate' => nil,
            'timespent' => 102_000,
            'status' => 'In Development'
          },
          'removal_from_sprint' => {
            'time' => nil,
            'time_estimate' => nil,
            'time_original_estimate' => nil,
            'timespent' => nil,
            'status' => nil
          },
          'sprint_start' => {
            'time_estimate' => 14_400,
            'time_original_estimate' => 14_400,
            'timespent' => 102_000,
            'status' => 'In Development'
          },
          'sprint_end' => {
            'time_estimate' => 0,
            'time_original_estimate' => 14_400,
            'timespent' => 196_380,
            'status' => 'Released'
          }
        }
      end

      it 'merges the expected sprint information' do
        result = described_class.run(source_data, processing_data)
        expected_sprint = result['sprints'].find { |s| s['name'] == expected_sprint_name }
        expect(expected_sprint).to eq(expected_sprint_information)
      end
    end
  end

  context 'with no sprint histories (case 8)' do
    let(:source_data) { SpecCase.get_jira_issues(8).first }
    let(:expected_sprint_name) { 'Sprint 2014-10-27' }
    let(:expected_sprint_information) do
      {
        'name' => expected_sprint_name,
        'started_at' => Time.parse('2014-10-27 09:40:00.000000000 +0100'),
        'ended_at' => Time.parse('2014-11-14 19:00:00.000000000 +0100'),
        'state' => 'CLOSED',
        'during_sprint' => {
          'added' => true,
          'removed' => false,
          'timespent_change' => nil,
          'time_estimate_change' => nil,
          'time_original_estimate_change' => nil
        },
        'addition_to_sprint' => {
          'time' => Time.parse('2014-11-03T14:16:05.355+0100'),
          'time_estimate' => nil,
          'time_original_estimate' => nil,
          'timespent' => nil,
          'status' => 'Open'
        },
        'removal_from_sprint' => {
          'time' => nil,
          'time_estimate' => nil,
          'time_original_estimate' => nil,
          'timespent' => nil,
          'status' => nil
        },
        'sprint_start' => {
          'time_estimate' => nil,
          'time_original_estimate' => nil,
          'timespent' => nil,
          'status' => 'Open'
        },
        'sprint_end' => {
          'time_estimate' => nil,
          'time_original_estimate' => nil,
          'timespent' => nil,
          'status' => 'In Development'
        }
      }
    end

    it 'merges the expected sprint information' do
      result = described_class.run(source_data, processing_data)
      expected_sprint = result['sprints'].find { |s| s['name'] == expected_sprint_name }
      expect(expected_sprint).to eq(expected_sprint_information)
    end
  end

  context 'specific case failing to calculate time estimate at sprint end in the middle of the sprint (case 10)' do
    let(:source_data) { SpecCase.get_jira_issues(10).first }
    let(:expected_sprint_name) { 'Sprint 2014-12-02' }

    it 'should return the expected result' do
      result = described_class.run(source_data, processing_data)
      expected_sprint = result['sprints'].find { |s| s['name'] == expected_sprint_name }
      expect(expected_sprint['sprint_end']['time_estimate']).to eq 4800
    end
  end

  # describe 'implementation TDD' do
  #
  #   describe '::sprint_related_histories(data, sprint_name)' do
  #     let(:sprint_name) { 'Sprint 2014-08-18' }
  #     it 'contains the histories from the one adding the sprint to the one removing it' do
  #       result = described_class.sprint_related_histories(processing_data, sprint_name)
  #       expect(result.length).to eq(10)
  #     end
  #   end
  # end
end
