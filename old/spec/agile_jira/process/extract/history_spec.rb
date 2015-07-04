require 'spec_helper'

describe Agilizer::Process::Extract::History do

  describe '::simplify(data)' do

    before(:all) do
      @data = SpecCase.get_data 3
      @result = described_class.simplify(@data)
    end

    it 'should only contain supported histories' do
      fields = @result.map { |r| r['field'] }.uniq.sort
      expect(fields).to eq %w(
        assignee
        sprints
        status
        time_estimate
        time_original_estimate
      )
    end

    describe 'flattening history items' do
      it 'should include the time of the containing history' do
        first_result = @result.first
        histories = HashDeepAccess.fetch @data, 'changelog.histories'
        history_for_first_result = histories.find do |history|
          original_field =
            case first_result['field']
            when 'sprints' then 'Sprint'
            when 'time_estimate' then 'timeestimate'
            when 'time_original_estimate' then 'timeoriginalestimate'
            else first_result['field']
            end
          history['items'].find { |i| i['field'] == original_field }
        end
        history_time = history_for_first_result['created']
        expect(first_result['time']).to eq(history_time)
      end
    end

    describe 'on field "Sprint"' do
      it 'should parse the values to arrays' do
        sprint_history = @result.find { |h| h['field'] == 'sprints' }
        expect(sprint_history['from']).to be_a Array
      end
    end

    describe 'on field "timeestimate"' do
      it 'should parse the values to an integer' do
        sprint_history = @result.find { |h| h['field'] == 'time_estimate' }
        from = sprint_history['from']
        to = sprint_history['to']
        expect(from.nil? || from.is_a?(Numeric)).to be true
        expect(to.nil? || to.is_a?(Numeric)).to be true
      end
    end

    describe 'on field "timeoriginalestimate"' do
      it 'should parse the values to integers' do
        sprint_history = @result.find { |h| h['field'] == 'time_original_estimate' }
        from = sprint_history['from']
        to = sprint_history['to']
        expect(from.nil? || from.is_a?(Numeric)).to be true
        expect(to.nil? || to.is_a?(Numeric)).to be true
      end
    end
  end
end
