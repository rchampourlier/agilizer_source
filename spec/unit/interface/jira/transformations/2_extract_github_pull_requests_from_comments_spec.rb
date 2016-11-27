require 'spec_helper'
require 'support/spec_case'
require 'agilizer/interface/jira/transformations/2_extract_github_pull_requests_from_comments'

describe Agilizer::Interface::JIRA::Transformations::ExtractGithubPullRequestsFromComments do

  describe '::run(data, _processing_data)' do
    subject { described_class.run(data, {}) }

    context 'case 1' do
      let(:data) { SpecCase.get_jira_issues(1).first }

      it 'extracts pull request ids to the "pull_request_ids" attribute' do
        expected_pull_request_ids = [
          { owner: 'the.company', repo: 'the.company', id: '1320' },
          { owner: 'the.company', repo: 'the.company', id: '1554' }
        ]
        expect(subject['github_pull_requests']).to eq(expected_pull_request_ids)
      end
    end
  end
end
