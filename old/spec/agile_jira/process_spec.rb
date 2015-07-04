require 'spec_helper'

describe Agilizer::Process do

  before(:all) do
    @datum = SpecCase.get_data(1)
  end

  describe '::read' do

    describe 'timespent' do
      it 'should return the correct value' do
        result = described_class.read(@datum, 'timespent')
        expect(result).to eq 196380
      end
    end

    describe 'created_at' do
      it 'should return the converted value' do
        result = described_class.read(@datum, 'created_at')
        expect(result).to eq Time.parse('2014-07-21T11:19:32.393+0200')
      end
    end

    describe 'sprints' do

      before(:all) do
        @result = described_class.read(@datum, 'sprints')
      end

      it 'should extract all the sprints' do
        expect(@result.count).to eq 6
      end

      it 'should returned the parsed sprint attributes' do
        expect(@result.first).to eq({
          'name' => 'Sprint 2014-07-18',
          'started_at' => '2014-07-21T14:43:51.181+02:00',
          'ended_at' => '2014-08-01T18:00:00.000+02:00',
          'state' => 'CLOSED'
        })
      end
    end
  end

  describe '::map' do

    before(:all) do
      @result = described_class.map(@datum)
    end

    it 'should correctly match the key' do
      expect(@result['key']).to eq 'TP-1130'
    end

    it 'should include all worklogs' do
      expect(@result['worklogs'].count).to eq 32
    end

    it 'should include all sprints' do
      expect(@result['sprints'].count).to eq 6
    end
  end

  describe '::process(data[, improve, enrich])' do

    subject do
      described_class.process(@datum, improve: improve, enrich: enrich)
    end

    let(:improve) { false }
    let(:enrich) { false }

    context 'improve = false, enrich = false' do

      it 'should include the key' do
        expect(subject['key']).to eq 'TP-1130'
      end

      it 'should include all sprints' do
        expect(subject['sprints'].count).to eq 6
      end

      describe 'worklogs' do

        it 'should contain "created_at"' do
          expect(subject['worklogs'].first.keys).to include('created_at')
        end

        it 'should contain "started_at"' do
          expect(subject['worklogs'].first.keys).to include('started_at')
        end

        it 'should not contain "time"' do
          expect(subject['worklogs'].first.keys).not_to include('time')
        end
      end

      describe 'simple history' do
        it 'should not be present' do
          expect(subject['history']).to be_nil
        end
      end
    end

    context 'improve = true, enrich = false' do
      let(:improve) { true }

      describe 'worklogs' do

        it 'should not contain "created_at"' do
          expect(subject['worklogs'].first.keys).not_to include('created_at')
        end

        it 'should not contain "started_at"' do
          expect(subject['worklogs'].first.keys).not_to include('started_at')
        end

        it 'should contain "time"' do
          expect(subject['worklogs'].first.keys).to include('time')
        end
      end

      describe 'simple history' do
        it 'should be present' do
          expect(subject['history']).not_to be_nil
        end
      end
    end

    context 'improve = true, enrich = true' do
      let(:improve) { true }
      let(:enrich) { true }

      it 'should add timespent to sprints' do
        expect(subject['sprints'][1]['timespent']).to eq(18600)
      end

      it 'should add the sprint scope information to each sprint' do
        sprint = subject['sprints'].find {|s| s['name'] == 'Sprint 2014-10-13' }

        expect(sprint['sprint_start']['time_estimate']).to eq 14400
        expect(sprint['sprint_start']['time_original_estimate']).to eq 14400
        expect(sprint['sprint_end']['time_estimate']).to eq 0
        expect(sprint['sprint_end']['time_original_estimate']).to eq 14400
      end

      describe 'worklogs enrichments' do

        %w(status sprint_name).each do |attribute|
          it "should add \"#{attribute}\"" do
            subject['worklogs'].each do |worklog|
              expect(worklog.keys).to include(attribute)
            end
          end
        end
      end
    end
  end
end
