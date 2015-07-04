require 'spec_helper'

describe Agilizer::Process::Extract do

  before(:all) do
    @data_1 = SpecCase.get_data(1)
    @data_2 = SpecCase.get_data(2)
    @data_4 = SpecCase.get_data(4)
    @data_7 = SpecCase.get_data(7)
  end

  let(:sprint_name) { sprint['name'] }
  let(:time) { Time.now }
  let(:field) { 'field' }
  let(:processed_data) { Agilizer::Process.process(data, enrich: false) }

  describe '::timespent_per_status(processed_data)' do
    let(:data) { @data_1 }
    let(:processed_data) do
      _processed_data = Agilizer::Process.process(data, enrich: false)
      Agilizer::Process::Enrich.add_status_to_worklogs(_processed_data, data)
    end

    it 'should return the expected result' do
      expected_result = [
        {
          'status' => 'In Development',
          'timespent' => 132000
        },
        {
          'status' => 'In Review',
          'timespent' => 55320
        },
        {
          'status' => 'In Functional Review',
          'timespent' => 9000
        },
        {
          'status' => 'Ready for Release',
          'timespent' => 60
        }
      ]
      result = described_class.timespent_per_status(processed_data)
      expect(result).to eq(expected_result)
    end
  end

  describe '::timespent_at_time(processed_data, time)' do
    let(:data) { @data_1 }

    context 'before issue creation' do
      let(:time) { processed_data['created_at'] - 1.hour }

      it 'should be nil' do
        result = described_class.timespent_at_time(processed_data, time)
        expect(result).to eq(nil)
      end
    end

    context 'now' do
      let(:time) { Time.now }

      it 'should be equal to the total timespent' do
        result = described_class.timespent_at_time(processed_data, time)
        expect(result).to eq(processed_data['timespent'])
      end
    end
  end

  describe '::value_at_time(processed_data, field, time)' do

    context 'processed_data not enriched with history' do
      let(:processed_data) { {} }
      it 'should raise an error' do
        expect {
          described_class.value_at_time(processed_data, field, time)
        }.to raise_error 'processed_data must already have been enriched with Improve::add_simple_history'
      end
    end

    context 'when there is no history' do
      let(:processed_data) do
        {
          'field' => 'current field value',
          'history' => []
        }
      end

      it 'should return the current value' do
        result = described_class.value_at_time(processed_data, field, time)
        expect(result).to eq('current field value')
      end
    end

    context 'with at least one history before the time' do

      let(:processed_data) do
        {
          'history' => [
            {
              'field' => 'field',
              'time' => (time - 1.second),
              'from' => 1,
              'to' => 2
            }
          ]
        }
      end

      it 'should return the "to" value of this history' do
        result = described_class.value_at_time(processed_data, field, time)
        expect(result).to eq 2
      end
    end

    context 'with no history before the time, at least one after' do

      let(:processed_data) do
        {
          'history' => [
            {
              'field' => 'field',
              'time' => (time + 1.second),
              'from' => 1,
              'to' => 2
            }
          ]
        }
      end

      it 'should return the "from" value of this history' do
        result = described_class.value_at_time(processed_data, field, time)
        expect(result).to eq 1
      end
    end

    context 'spec data 1' do
      let(:data) { @data_1}
      subject { described_class.value_at_time(processed_data, field, time) }

      context 'sprint "Sprint 2014-10-13"' do
        let(:sprint) { 'Sprint 2014-10-13' }

        context 'time_original_estimate' do
          let(:field) { 'time_original_estimate'}

          context 'at 2014-10-13 13:35:00 +0200' do
            let(:time) { Time.parse '2014-10-13 13:35:00 +0200' }

            it { should eq 14400 }
          end
        end
      end
    end
  end
end
