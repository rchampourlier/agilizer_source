require 'spec_helper'
require 'support/spec_case'
require 'agilizer/interface/jira/transformations/1_basic_mapping'
require 'agilizer/interface/jira/transformations/3_add_final_fix_version'

describe Agilizer::Interface::JIRA::Transformations::AddFinalFixVersion do
  let(:source_data) { SpecCase.get_jira_issues(1).first }
  let(:processing_data) do
    Agilizer::Interface::JIRA::Transformations::BasicMapping.run(source_data, {})
  end

  describe '::run(source_data, processing_data)' do

    it 'adds the last released fix version' do
      enriched = described_class.run(source_data, processing_data)
      result = enriched['final_fix_version']
      expect(result).to eq('2014-10-24')
    end
  end
end
