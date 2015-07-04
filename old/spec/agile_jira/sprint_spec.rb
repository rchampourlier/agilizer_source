require 'spec_helper'
require 'agilizer/sprint'

describe Agilizer::Sprint do

  before(:all) do
    datas = [SpecCase.get_data(1), SpecCase.get_data(2)]
    @processed_datas = datas.map { |dc| Agilizer::Process.process(dc) }
  end

  let(:processed_datas) { @processed_datas }

  describe '::names' do

    it 'should return the expected sprint names' do
      allow(Agilizer::Analyze::Search).to receive(:sprints_by_essence_updated_at) do
        @processed_datas.inject({}) do |hash, essence|
          hash[essence['updated_at']] = essence['sprints']
          hash
        end
      end
      result = described_class.names
      expect(result).to eq [
        'Sprint 2014-07-18',
        'Sprint 2014-08-18',
        'Sprint 2014-09-01',
        'Sprint 2014-09-15',
        'Sprint 2014-09-29',
        'Sprint 2014-10-13'
      ]
    end
  end

  describe '::details' do

    before do
      allow(Agilizer::Analyze::Search).to receive(:processed_datas_for_sprint) { @essences }
    end

    let(:sprint_name) { 'Sprint 2014-10-13' }
    subject { described_class.details(sprint_name) }

    it 'should contain the sprint name' do
      expect(subject['name']).to eq sprint_name
    end

    it 'should contain the sprint start date' do
      expect(subject['started_at']).to eq Time.parse('2014-10-13T13:35:00.000+02:00')
    end

    it 'should contain the sprint end date' do
      expect(subject['ended_at']).to eq Time.parse('2014-10-24T19:00:00.000+02:00')
    end
  end

  describe '::issue_sprint_information(issue, sprint_name)' do
    let(:essence) { @processed_datas.first }
    let(:sprint_name) { 'Sprint 2014-07-18' }

    it 'should return the issue sprint information for the specified sprint' do
      result = described_class.issue_sprint_information(essence, sprint_name)
      expect(result['name']).to eq(sprint_name)
    end
  end

  describe '::statistics_from_issues(processed_datas, sprint_name)' do
    let(:processed_datas) do
      [{
        'time_estimate' => 66,
        'sprints' => [{
          'name' => 'Sprint 2014-10-13',
          'timespent' => 1000,
          'during_sprint' => {
            'added' => false,
            'time_estimate_change' => -5,
            'time_original_estimate_change' => 0
          },
          'addition_to_sprint' => {
            'time_estimate' => nil,
            'time_original_estimate' => nil
          }
        }]
      }, {
        'time_estimate' => 33,
        'sprints' => [{
          'name' => 'Sprint 2014-10-13',
          'timespent' => 2000,
          'during_sprint' => {
            'added' => true,
            'time_estimate_change' => 10,
            'time_original_estimate_change' => -20
          },
          'addition_to_sprint' => {
            'time_estimate' => 50,
            'time_original_estimate' => 60
          }
        }]
      }]
    end

    let(:sprint_name) { 'Sprint 2014-10-13' }

    it 'should return the expected statistics' do
      result = described_class.statistics_from_issues(processed_datas, sprint_name)
      expect(result).to eq({
        'count' => 2,
        'timespent' => 3000,
        'time_estimate' => 99,
        'added_during_sprint' => {
          'count' => 1,
          'timespent' => 2000,
          'time_estimate' => 50,
          'time_original_estimate' => 60
        },
        'changes_during_sprint' => {
          'time_estimate' => 5,
          'time_original_estimate' => -20
        }
      })
    end
  end
end
