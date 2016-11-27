require 'spec_helper'
require 'support/spec_case'
require 'agilizer/interface/jira/transformations/1_basic_mapping'
require 'agilizer/interface/jira/transformations/2_add_simple_history'
require 'agilizer/interface/jira/transformations/2_set_worklog_time'
require 'agilizer/interface/jira/transformations/3_calculate_time_per_status'

describe Agilizer::Interface::Jira::Transformations::CalculateTimePerStatus do
  let(:source_data) { SpecCase.get_jira_issues(1).first }
  let(:processed_data) do
    processing_data = Agilizer::Interface::Jira::Transformations::BasicMapping.run(source_data, {})
    processing_data = Agilizer::Interface::Jira::Transformations::AddSimpleHistory.run(source_data, processing_data)
    Agilizer::Interface::Jira::Transformations::SetWorklogTime.run(source_data, processing_data)
  end

  describe '::run(source_data, processing_data)' do
    subject { described_class.run(source_data, processed_data) }

    it 'sums expected times in each status' do
      times = subject['time_per_status']
      expect(times).to eq(
        'In Development' => 3_252_786.0560000013,
        'In Functional Review' => 985_016.292,
        'In Review' => 2_471_908.582,
        'Open' => 965_547.6070000001,
        'Ready for Release' => 83_468.692,
        'Selected for Development' => 460_664.188
      )
    end
  end
end
