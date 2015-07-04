require 'spec_helper'
require 'support/spec_case'
require 'agilizer/interface/jira/transformations/2_add_simple_history'

describe Agilizer::Interface::Jira::Transformations::AddSimpleHistory do

  describe '::run(source_data, processing_data)' do

    before(:all) do
      @source_data = SpecCase.get_jira_issues(3).first
      @result = described_class.run(@source_data, {})['history']
    end

    it 'should only contain supported historiesra_issues' do
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
        histories = HashOp::DeepAccess.fetch @source_data, 'changelog.histories'
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
