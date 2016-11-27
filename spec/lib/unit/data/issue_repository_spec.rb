# frozen_string_literal: true
require "spec_helper"
require "agilizer/data/issue_repository"

describe Agilizer::Data::IssueRepository do

  describe "::stringify_keys" do

    context "for nil" do
      it "returns nil" do
        expect(described_class.stringify_keys(nil)).to eq(nil)
      end
    end

    context "for hash with mixed keys" do
      it "stringify symbol keys" do
        hash = {
          :symbol => "symbol",
          "string" => "string"
        }
        expected_result = {
          "symbol" => "symbol",
          "string" => "string"
        }
        expect(described_class.stringify_keys(hash)).to eq(expected_result)
      end
    end
  end
end
