require 'spec_helper'

describe Agilizer::Process::Improve do

  describe '::add_simple_history' do

    before do
      allow(Agilizer::Process::Extract::History).to receive(:simplify) do |data|
        "simple_history(#{data})"
      end
    end

    it 'should add the History::simplify(data) to essence[\'history\']' do
      result = described_class.add_simple_history({}, 'data')
      expect(result['history']).to eq 'simple_history(data)'
    end
  end
end
