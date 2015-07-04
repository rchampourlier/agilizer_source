require 'spec_helper'
require 'agilizer/update_manager'
require 'agilizer/issue'
require 'active_support/all'

describe Agilizer::UpdateManager do
  subject { described_class }

  describe '::run(data)' do
    let(:identifier) { 'identifier' }
    let(:source) { 'source' }
    let(:created_at) { Time.now - 1.month }
    let(:updated_at) { Time.now - 1.week }
    let(:data) do
      {
        identifier: identifier,
        source: source,
        created_at: created_at,
        updated_at: updated_at
      }
    end

    context 'new issue' do
      before do
        expect(Agilizer::Issue.where(identifier: identifier, source: source).count)
          .to eq(0)
      end

      it 'saves the data in a new issue' do
        expect {
          subject.run(data)
        }.to change { Agilizer::Issue.count }.by(1)
        issue = Agilizer::Issue.last
        expect(issue.identifier).to eq(identifier)
        expect(issue.updated_at - updated_at).to be < 0.001
      end
    end

    context 'existing issue' do
      let(:existing_issue) do
        Agilizer::Issue.new(
          identifier: identifier,
          source: source,
          created_at: Time.now - 1.year,
          updated_at: Time.now - 1.year,
          time_original_estimate: 10000
        )
      end

      let!(:issue) do
        Agilizer::Issue.create(existing_issue.attributes)
      end

      it 'saves updates the existing data with the new data' do
        subject.run(data)
        issue.reload
        expect(issue.created_at - created_at).to be < 0.001
      end

      it 'doesn\'t overwrite fields not present in the new data' do
        subject.run(data)
        issue.reload
        expect(issue.time_original_estimate).to eq(existing_issue.time_original_estimate)
      end
    end
  end
end
