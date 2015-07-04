require 'spec_helper'

describe Agilizer::Process::Extract::Sprint do

  before do
    @data_1 = SpecCase.get_data 1
    @data_6 = SpecCase.get_data 6
    @data_7 = SpecCase.get_data 7
    @data_8 = SpecCase.get_data 8
    @data_10 = SpecCase.get_data 10
  end

  let(:data) { @data_1 }
  let(:processed_data) do
    Agilizer::Process.process(data, enrich: false)
  end

  describe '::information(processed_data, sprint_name)' do

    context 'spec case 1, sprint 2014-10-13' do
      let(:data) { @data_1 }
      let(:sprint_name) { 'Sprint 2014-10-13' }

      it 'should be the expected result' do
        result = described_class.information(processed_data, sprint_name)
        expect(result.except('time_estimate_changes_during_sprint')).to eq({
          'during_sprint' => {
            'added' => false,
            'removed' => false,
            'timespent_change' => 94380,
            'time_estimate_change' => -14400,
            'time_original_estimate_change' => 0
          },
          'addition_to_sprint' => {
            'time' => Time.parse('2014-10-11T09:27:42.876+0200'),
            'time_estimate' => 0,
            'time_original_estimate' => nil,
            'timespent' => 102000,
            'status' => 'In Development',
          },
          'removal_from_sprint' => {
            'time' => nil,
            'time_estimate' => nil,
            'time_original_estimate' => nil,
            'timespent' => nil,
            'status' => nil
          },
          'sprint_start' => {
            'time_estimate' => 14400,
            'time_original_estimate' => 14400,
            'timespent' => 102000,
            'status' => 'In Development'
          },
          'sprint_end' => {
            'time_estimate' => 0,
            'time_original_estimate' => 14400,
            'timespent' => 196380,
            'status' => 'Released'
          }
        })
      end
    end

    context 'with no sprint histories (case 8)' do
      let(:data) { @data_8 }
      let(:sprint_name) { 'Sprint 2014-10-27' }

      it 'should return the expected results' do
        result = described_class.information(processed_data, sprint_name)
        expect(result.except('time_estimate_changes_during_sprint')).to eq({
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
            'status' => 'Open',
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
        })
      end
    end

    context 'specific case failing to calculate time estimate at sprint end in the middle of the sprint (case 10)' do
      let(:data) { @data_10 }
      let(:sprint_name) { 'Sprint 2014-12-02' }

      it 'should return the expected result' do
        result = described_class.information(processed_data, sprint_name)
        expect(result['sprint_end']['time_estimate']).to eq 4800
      end
    end
  end

  describe '::related_histories(processed_data, sprint_name)' do
    let(:data) { @data_1 }
    let(:sprint_name) { 'Sprint 2014-08-18' }

    it 'should contain the histories from the one adding the sprint to the one removing it' do
      result = described_class.related_histories(processed_data, sprint_name)
      expect(result.length).to eq 10
    end
  end

  describe '::select_worklogs' do

    def select_worklogs(processed_data)
      sprint = processed_data['sprints'][1]
      worklogs = processed_data['worklogs']
      described_class.select_worklogs(sprint, worklogs)
    end

    context 'sprint with no start date' do

      let(:processed_data) do
        content = SpecCase.get_mapped_data(1)
        content['sprints'][1]['started_at'] = nil
        content['sprints'][1]['ended_at'] = nil
        content
      end

      it 'should return no worklogs' do
        result = select_worklogs(processed_data)
        expect(result).to be_empty
      end
    end

    context 'sprint with only start date' do
      let(:data) { @data_1 }
      before { processed_data['sprints'][1]['ended_at'] = nil }

      it 'should return the matching worklogs' do
        result = select_worklogs(processed_data)
        expect(result.length).to eq(32)
        expect(Agilizer::Process::Worklog.timespent(result)).to eq(196380)
      end
    end

    context 'sprint with both start and end date' do
      let(:data) { @data_1 }

      it 'should return the matching worklogs' do
        result = select_worklogs(processed_data)
        expect(result.length).to eq 4
        expect(Agilizer::Process::Worklog.timespent(result)).to eq 18600
      end
    end
  end
end
