require 'spec_helper'
require 'support/spec_case'
require 'agilizer/interface/jira/transformations/1_basic_mapping'

describe Agilizer::Interface::Jira::Transformations::BasicMapping do

  describe '::run(data, _processing_data)' do
    subject { described_class.run(data)}
    let(:data) { { 'key' => 'issue_key' } }

    it 'sets the "source" to "jira"' do
      expect(subject['source']).to eq('jira')
    end

    it 'sets the "identifier" to JIRA issue\'s key' do
      expect(subject['identifier']).to eq('issue_key')
    end

    context 'case 1' do
      let(:data) { SpecCase.get_jira_issues(1).first }

      it 'maps JIRA issue data to Agilizer\'s' do
        expect(subject.keys).to include(*%w(
          source identifier
          created_at updated_at
          project_name project_key
          status
        ))
      end
    end
  end
end
