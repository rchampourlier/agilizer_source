require 'spec_helper'
require 'support/spec_case'
require 'agilizer/interface/jira/transformations/1_basic_mapping'
require 'agilizer/interface/jira/transformations/2_add_simple_history'
require 'agilizer/interface/jira/transformations/2_set_worklog_time'
require 'agilizer/interface/jira/transformations/3_add_timespent_to_sprints'

describe Agilizer::Interface::Jira::Transformations::AddTimespentToSprints do

  def process_data(source_data)
    processing_data = Agilizer::Interface::Jira::Transformations::BasicMapping.run(source_data, {})
    processing_data = Agilizer::Interface::Jira::Transformations::AddSimpleHistory.run(source_data, processing_data)
    Agilizer::Interface::Jira::Transformations::SetWorklogTime.run(source_data, processing_data)
  end

  let(:source_data) { SpecCase.get_jira_issues(1).first }
  let(:processing_data) { process_data(source_data) }

  describe '::run(source_data, processing_data)' do

    context 'missing sprints or worklogs data' do
      it 'returns the original processing_data' do
        missing_sprints_processing_data = processing_data.except('sprints')
        result = described_class.run(source_data, missing_sprints_processing_data)
        expect(result).to eq(missing_sprints_processing_data)
      end
    end

    it 'adds timespent to each sprint' do
      result = described_class.run(source_data, processing_data)
      sprints = result['sprints']

      sum = 0
      sprints.each do |sprint|
        timespent = sprint['timespent']
        expect(timespent).not_to be_nil
        sum += timespent
      end
      expect(sum).to eq(processing_data['timespent'])
    end
  end

  describe 'implementation methods' do

    describe '::worklogs_select(sprint, worklogs)' do

      def select_worklogs(processing_data)
        sprint = processing_data['sprints'][1]
        worklogs = processing_data['worklogs']
        described_class.worklogs_select(sprint, worklogs)
      end

      context 'sprint with no start date' do

        let(:processing_data) do
          content = process_data(source_data)
          content['sprints'][1]['started_at'] = nil
          content['sprints'][1]['ended_at'] = nil
          content
        end

        it 'should return no worklogs' do
          result = select_worklogs(processing_data)
          expect(result).to be_empty
        end
      end

      context 'sprint with only start date' do
        let(:processing_data) { process_data(source_data) }
        before { processing_data['sprints'][1]['ended_at'] = nil }

        it 'should return the matching worklogs' do
          result = select_worklogs(processing_data)
          expect(result.length).to eq(32)
          expect(described_class.worklogs_timespent(result)).to eq(196_380)
        end
      end

      context 'sprint with both start and end date' do

        it 'should return the matching worklogs' do
          result = select_worklogs(processing_data)
          expect(result.length).to eq(4)
          expect(described_class.worklogs_timespent(result)).to eq(18_600)
        end
      end
    end
  end
end
