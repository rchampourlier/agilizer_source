require 'rest-client'

module Agilizer

  # Enrichments are post-processing operations that use the stored
  # issue data and enrich it. They are not expected to be performed
  # on a synchrone basis when the issue is created or updated since
  # they may require long processing time or rely on external services
  # (such as Github API).
  #
  # Enrichments must be independent from each other.
  module Enrichments

    # Enrich issue with source code change data retrieved from
    # the Github pull request URLs contained in the issue
    # "github_pull_requests" attribute.
    module SourceCodeChanges

      # @param issue_identifier [String] the identifier of the issue
      #   to perform the enrichment on
      def run(issue_identifier)
        issue = Issue.where(identifier: issue_identifier).first
        return if issue.nil?

        changed_files = issue.github_pull_requests.map do |pull_request|
          fetch_changed_files(pull_request)
        end.flatten.uniq.compact
        return issue if issue.changed_files == changed_files

        issue.changed_files = changed_files
        issue.save!
        issue
      end
      module_function :run

      # IMPLEMENTATION

      # @param pull_request [Hash] an hash representing the pull request,
      #   containing :owner, :repo and :id attributes
      def fetch_changed_files(pull_request)
        pr_data = fetch_pr_data(pull_request)
        sha = pr_data['merge_commit_sha']
        return nil if sha.nil?

        merge_commit_data = fetch_github_commit(pull_request, sha)
        merge_commit_data['files'].map { |f| f['filename'] }

      rescue RestClient::ResourceNotFound => error
        # TODO
        require 'pry'; binding.pry
      end
      module_function :fetch_changed_files

      def fetch_pr_data(pull_request)
        owner = pull_request[:owner]
        repo = pull_request[:repo]
        id = pull_request[:id]
        fetch_github_pull_request(owner, repo, id)
      end
      module_function :fetch_pr_data

      def fetch_github_pull_request(owner, repo, id)
        url = "https://api.github.com/repos/#{owner}/#{repo}/pulls/#{id}"
        response = github_request(url).execute
        JSON.parse(response.to_str)
      end
      module_function :fetch_github_pull_request

      def fetch_github_commit(pull_request, sha)
        owner = pull_request[:owner]
        repo = pull_request[:repo]
        url = "https://api.github.com/repos/#{owner}/#{repo}/commits/#{sha}"
        response = github_request(url).execute
        JSON.parse(response.to_str)
      end
      module_function :fetch_github_commit

      def github_request(url)
        RestClient::Request.new(
          method: :get,
          url: url,
          headers: {
            accept: :json,
            content_type: :json,
            Authorization: github_request_auth_header
          }
        )
      end
      module_function :github_request

      def github_request_auth_header
        username = ENV['AGILIZER_GITHUB_API_USERNAME']
        password = ENV['AGILIZER_GITHUB_API_PASSWORD']
        auth_token = "#{username}:#{password}"
        "Basic #{Base64.encode64(auth_token).strip}"
      end
      module_function :github_request_auth_header
    end
  end
end