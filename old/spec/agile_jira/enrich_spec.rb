require 'spec_helper'

describe Agilizer::Process::Enrich do

  before(:all) do
    @data_1 = SpecCase.get_data(1)
    @data_7 = SpecCase.get_data(7)
  end

  let(:processed_data) { Agilizer::Process.process(data, enrich: false) }

  describe '::add_status_to_worklogs' do
    let(:data) { @data_1 }

    it 'should add the expected status' do
      result = described_class.add_status_to_worklogs(processed_data, data)
      expect(result['worklogs'].first['status']).to eq('In Development')
    end
  end

  describe '::add_sprint_name_to_worklogs' do
    let(:data) { @data_1 }

    it 'should add the expected sprint name' do
      result = described_class.add_sprint_name_to_worklogs(processed_data, data)
      expect(result['worklogs'].first['sprint_name']).to eq('Sprint 2014-08-18')
    end
  end

  describe '::add_timespent_to_sprints' do
    let(:data) { @data_1 }

    it 'should return the original processed_data content if missing sprints or worklogs data' do
      missing_sprints_processed_data = essence.except('sprints')
      result = described_class.add_timespent_to_sprints(missing_sprints_processed_data)
      expect(result).to eq missing_sprints_processed_data
    end

    it 'should correctly add timespent to each sprint' do
      result = described_class.add_timespent_to_sprints(processed_data)
      sprints = result['sprints']

      sum = 0
      sprints.each do |sprint|
        timespent = sprint['timespent']
        expect(timespent).not_to be_nil
        sum += timespent
      end
      expect(sum).to eq processed_data['timespent']
    end
  end

  describe '::add_sprint_information(processed_data)' do
    let(:data) { @data_7 }

    it 'should merge all sprint information for each sprint' do
      allow(Agilizer::Process::Extract::Sprint).to receive(:information) do |processed_data, sprint_name|
        { 'processed_data' => sprint_name }
      end
      result = described_class.add_sprint_information(processed_data)
      result['sprints'].each do |sprint|
        expect(sprint['processed_data']).to eq(sprint['name'])
      end
    end
  end

  describe '::add_final_fix_version(processed_data)' do
    let(:data) { @data_1 }

    it 'should add the last released fix version' do
      enriched = described_class.add_final_fix_version(processed_data)
      result = enriched['final_fix_version']
      expect(result).to eq({
        'name' => '2014-10-24',
        'date' => '2014-10-24',
        'released' => true
      })
    end
  end
end
