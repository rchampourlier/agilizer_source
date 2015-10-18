require 'spec_helper'
require 'agilizer/enrichments/source_code_changes'
require 'agilizer/issue'

describe Agilizer::Enrichments::SourceCodeChanges do

  describe '.run(issue_identifier)' do
    subject { described_class.run(issue_identifier) }

    context 'issue does not exist' do
      let(:issue_identifier) { 'unknown' }

      it 'returns nil' do
        expect(subject).to eq(nil)
      end
    end

    context 'issue exists' do
      before { SpecCase.load_issues(1) }

      let(:issue_identifier) do
        Agilizer::Issue.last.identifier
      end
      let(:expected_pull_request_urls) do
        %w(https://api.github.com/repos/the.company/the.company/pulls/1320
           https://api.github.com/repos/the.company/the.company/pulls/1554)
      end

      let(:github_response) { {} }

      def github_request(response)
        double('RestClient::Request', execute: response.to_json)
      end


      it 'fetches all associated pull request on Github' do
        expect(RestClient::Request)
          .to receive(:new)
          .twice do |options|
            expect(options[:url]).to be_in(expected_pull_request_urls)
          end
          .and_return(github_request(github_response))
        subject
      end

      context 'pull request empty response' do
        before do
          allow(RestClient::Request)
            .to receive(:new)
            .and_return(github_request(github_response))
        end

        it 'does not change the issue' do
          expect(subject.changed_files).to eq([])
        end
      end

      context 'pull request with merge commit' do
        let(:github_pr_response) { { 'merge_commit_sha' => 'SHA' } }
        let(:github_commit_response) do
          { 'files' => [
            { 'filename' => 'file1' },
            { 'filename' => 'file2' }
          ] }
        end

        before do
          expect(RestClient::Request)
            .to receive(:new)
            .exactly(4).times do |options|
              if options[:url] =~ %r{/pulls/}
                github_request(github_pr_response)
              else
                expect(options[:url])
                  .to eq('https://api.github.com/repos/the.company/the.company/commits/SHA')
                github_request(github_commit_response)
              end
            end
        end

        it 'fetches the merge commit of the associated pull request' do
          subject
        end

        it 'writes the merge commit files to the issue' do
          expect(subject.changed_files).to eq(%w(file1 file2))
        end
      end
    end
  end
end
