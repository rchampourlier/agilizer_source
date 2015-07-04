require 'spec_helper'
require 'api_helper'
require 'app/api'

include Agilizer

describe App::API do
  include APIHelper

  describe 'GET /api/sprints' do

    it 'is successful' do
      get '/api/sprints'
      expect(response_status).to eq(200)
    end
  end

  describe 'GET /api/issues' do

    context 'no filter' do
      it 'is successful' do
        get '/api/issues'
        expect(response_status).to eq(200)
      end
    end

    context 'filter "sprint_name"' do
      let(:sprint_name) { 'Sprint-Name' }

      it 'is successful' do
        get "/api/issues?sprint_name=#{sprint_name}"
        expect(response_status).to eq(200)
      end

      it 'performs the expected search' do
        expect(Search).to receive(:essences_with_filter) do |filter|
          expect(filter[:sprint_name]).to eq(sprint_name)
          []
        end
        get "/api/issues?sprint_name=#{sprint_name}"
      end

      it 'calculates the sprint statistics on result issues' do
        expect(Search).to receive(:essences_with_filter) { [:issue] }
        expect(Sprint).to receive(:statistics_from_issues) do |issues, sprint_name|
          expect(issues).to eq([:issue])
          {}
        end
        get "/api/issues?sprint_name=#{sprint_name}"
      end

      it 'returns an hash with statistics and entries' do
        get "/api/issues?sprint_name=#{sprint_name}"
        expect(parsed_response['statistics']['count']).to eq(0)
        expect(parsed_response['entries']).to eq([])
      end
    end

    context 'filter "added_during_sprint"' do
      let(:sprint_name) { 'Sprint-Name' }

      it 'performs the expected search' do
        expect(Search).to receive(:essences_with_filter) do |filter|
          expect(filter[:added_during_sprint]).to eq(sprint_name)
          []
        end
        get "/api/issues?added_during_sprint=#{sprint_name}"
      end
    end

    context 'filter "types"' do
      it 'performs the expected search' do
        expect(Search).to receive(:essences_with_filter) do |filter|
          expect(filter[:types]).to eq(['bug', 'improvement'])
          []
        end
        get "/api/issues?types=bug,improvement"
      end
    end
  end
end
