require 'spec_helper'

describe Agilizer::Process::Worklog do

  let(:essence) { SpecCase.get_mapped_data(1) }
  let(:worklogs) { essence['worklogs'].map(&:stringify_keys) }

  describe '::timespent' do
    it 'should correctly calculate timespent from worklogs' do
      result = described_class.timespent(worklogs)
      expect(result).to eq 196380
    end
  end

  describe '::timespent_per_author' do
    it 'should correctly cumulate timespent per person' do
      expected_result = [
        { 'author' => 'team.member.1', 'timespent' => 134400 },
        { 'author' => 'team.member.6', 'timespent' => 2700 },
        { 'author' => 'team.member.5', 'timespent' => 4200 },
        { 'author' => 'team.member.7', 'timespent' => 55080 }
      ]

      result = described_class.timespent_per_author(worklogs)
      expected_result.each do |expected_worklog|
        expect(result).to include expected_worklog
      end
    end
  end

  describe '::rich_worklogs' do

    it 'should return the enriched worklogs of the essence' do
      rich_worklogs = described_class.rich_worklogs(essence)
      rich_worklog = rich_worklogs.first

      %w(key summary).each do |enrichment|
        expect(rich_worklog["issue_#{enrichment}"]).to eq(essence[enrichment])
      end
    end
  end

  describe '::set_time(worklog)' do

    let(:time) { Time.now}

    let(:worklog) do
      {
        'created_at' => time,
        'started_at' => time - 1.hour,
        'timespent' => 1.hour
      }
    end

    subject { described_class.set_time(worklog) }

    context '"started_at" before "created_at"' do
      it 'should set "time" to "started_at"' do
        expect(subject['time']).to eq(time - 1.hour)
      end
    end

    context '"started_at" equal to "created_at"' do

      before do
        worklog.merge! 'started_at' => time
      end

      it 'should set "time" to "created_at" minus "timespent"' do
        expect(subject['time']).to eq(time - 1.hour)
      end
    end
  end
end
