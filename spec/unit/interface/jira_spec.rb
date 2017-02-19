# frozen_string_literal: true
require "spec_helper"
require "agilizer/interface/jira"
require "jira_cache"
require "jira_cache/client"

describe Agilizer::Interface::JIRA do
  subject { described_class.new }
  let(:project_key) { "project_key" }
  let(:client) { double("JiraCache::Client") }
  let(:client_options) { { a: 1 } }
  let(:notifier) { double("Notifier") }

  describe "::import_project(project_key)" do
    it "runs JiraCache.sync_issues(client: client, project_key: project_key)" do
      expect(subject).to receive(:client).and_return(client)
      expect(JiraCache).to receive(:sync_issues).with(client: client, project_key: project_key)
      subject.import_project(project_key)
    end
  end
end
