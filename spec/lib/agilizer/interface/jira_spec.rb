require 'spec_helper'
require 'agilizer/interface/jira'
require 'jira_cache'
require 'jira_cache/client'

describe Agilizer::Interface::Jira do
  let(:project_key) { 'project_key' }
  let(:client) { double('JiraCache::Client') }
  let(:client_options) { { a: 1 } }
  let(:notifier) { double('Notifier') }

  describe '::import(project_key)' do
    it 'runs JiraCache.sync_issues(client, project_key)' do
      expect(described_class).to receive(:client).and_return(client)
      expect(JiraCache).to receive(:sync_issues).with(client, project_key)
      described_class.import(project_key, client_options)
    end
  end

  describe '::client(options)' do
    it 'builds a JiraCache::Client with an EventsPublisher instance as notifier' do
      expect(described_class).to receive(:notifier).and_return(notifier)
      expect(JiraCache::Client)
        .to receive(:new)
        .with(client_options.merge(notifier: notifier))
        .and_return(client)
      expect(described_class.client(client_options)).to eq(client)
    end
  end

  describe '::notifier' do
    it 'returns a new Notifier instance' do
      expect(Agilizer::Interface::Jira::Notifier)
        .to receive(:new)
        .and_return(notifier)
      expect(described_class.notifier).to eq(notifier)
    end
  end
end
