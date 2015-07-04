require 'spec_helper'
require 'search'
require 'data/issue_document'

describe Agilizer::Search do

  describe '::issues_with_worklogs_between(from, to)' do

    it 'should return the matching issues' do
      data_items = SpecCase.get_mapped_data(1, 5)
      data_items.each do |data|
        Agilizer::Data::IssueDocument.create_or_update(data)
      end

      from = Time.parse '2014-08-01'
      to = Time.parse '2014-09-01'

      result = described_class.issues_with_worklogs_between(from, to)
      expect(result.count).to eq 1
      expect(result.first['key']).to eq 'TP-1130'
    end
  end
end
