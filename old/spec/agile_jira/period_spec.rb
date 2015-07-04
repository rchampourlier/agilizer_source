require 'spec_helper'
require 'period'

describe Agilizer::Period do

  describe '::all' do

    before(:each) do
      @subject = described_class.all
    end

    it 'should contain the correct "today" period object' do
      expect(@subject).to include({
        identifier: 'today',
        label: 'Today'
      })
    end

    it 'should contain the other expected period' do
      expected_identifiers = %w(
        today
        yesterday
        current_week
        last_week
        current_sprint
        last_sprint
        current_month
        last_month
      )
      expect(@subject.map { |p| p[:identifier] }).to eq expected_identifiers
    end
  end
end
