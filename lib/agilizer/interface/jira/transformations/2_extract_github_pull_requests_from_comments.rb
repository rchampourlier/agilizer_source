require 'hash_op/mapping'

module Agilizer
  module Interface
    module Jira
      module Transformations

        # A JobTeaser specific transformation which extracts the
        # pull requests associated to the issue from the
        # comments.
        #
        # It's in our workflow to add a comment to the JIRA
        # with a link to the pull request when the issue is
        # released from development.
        module ExtractGithubPullRequestsFromComments

          # Extracts the Github pull request URLs by looking for them in the comments
          # of the issue.
          #
          # @param source_data [Hash] source JIRA issue hash
          # @param processing_data [Hash] Agilizer issue hash, ongoing transformations
          # @return [Hash] new hash from merging `processing_data` with the extracted pull
          #   requests ids in "github_pull_request_ids"
          def run(source_data, processing_data)
            comment_bodies = source_data['fields']['comment']['comments'].map { |c| c['body'] }
            pull_requests = comment_bodies.map do |body|
              matches = body.scan(%r{https://github.com/([^/]+)/([^/]+)/pull/(\d+)})
              matches.map { |a| Hash[[:owner, :repo, :id].zip(a)] }
            end.flatten.uniq
            processing_data.merge 'github_pull_requests' => pull_requests
          end
          module_function :run
        end
      end
    end
  end
end
