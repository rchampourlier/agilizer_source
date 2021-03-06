# frozen_string_literal: true
require "rest-client"
require "base64"
require "agilizer/data/issue_repository"

module Agilizer
  module Enrichments

    # Enrich issue with source code change data retrieved from
    # the Github pull request URLs contained in the issue
    # "github_pull_requests" attribute.
    #
    # TODO: scope the pull request fetching to issues that have
    #   been modified and may have new source code changes.
    module SourceCodeChanges

      def run_for_applicable_issues
        issues = Data::IssueRepository.all_with_github_pull_requests
        issues.each do |hash|
          identifier = hash[:identifier]
          run(identifier)
        end
      end
      module_function :run_for_applicable_issues

      # @param issue_identifier [String] the identifier of the issue
      #   to perform the enrichment on
      def run(issue_identifier)
        data = Data::IssueRepository.find_by(identifier: issue_identifier)
        return if data.nil?

        github_pull_requests = data["github_pull_requests"]
        changed_files = github_pull_requests.map do |pull_request|
          fetch_changed_files(pull_request)
        end.flatten.uniq.compact
        return data if data["changed_files"] == changed_files

        data["changed_files"] = changed_files
        Data::IssueRepository.insert(data)
        data
      end
      module_function :run

      # IMPLEMENTATION

      # @param pull_request [Hash] an hash representing the pull request,
      #   containing :owner, :repo and :id attributes
      def fetch_changed_files(pull_request)
        pr_data = fetch_pr_data(pull_request)
        return nil if pr_data.nil?

        sha = pr_data["merge_commit_sha"]
        return nil if sha.nil?

        merge_commit_data = fetch_github_commit(pull_request, sha)
        merge_commit_data["files"].map { |f| f["filename"] }
      end
      module_function :fetch_changed_files

      def fetch_pr_data(pull_request)
        owner = pull_request["owner"]
        repo = pull_request["repo"]
        id = pull_request["id"]
        fetch_github_pull_request(owner, repo, id)
      end
      module_function :fetch_pr_data

      def fetch_github_pull_request(owner, repo, id)
        url = "https://api.github.com/repos/#{owner}/#{repo}/pulls/#{id}"
        response = github_request(url).execute
        JSON.parse(response.to_str)
      rescue RestClient::ResourceNotFound => _error
        # TODO: log something, in case it"s raised
        return nil
      end
      module_function :fetch_github_pull_request

      def fetch_github_commit(pull_request, sha)
        owner = pull_request["owner"]
        repo = pull_request["repo"]
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
        username = ENV["GITHUB_API_USERNAME"]
        password = ENV["GITHUB_API_PASSWORD"]
        auth_token = "#{username}:#{password}"
        "Basic #{Base64.strict_encode64(auth_token).strip}"
      end
      module_function :github_request_auth_header
    end
  end
end
