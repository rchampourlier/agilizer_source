require 'grape'
require 'filter'
require 'sprint'

module Agilizer
  module App

    class API < Grape::API
      version 'v1', using: :header, vendor: 'agilizer'
      format :json
      prefix :api

      resource :issues do

        desc <<-END
        Return essence of all issues.
        Filterable with the following params:
          - sprint_name=<sprint name>: sprint name, URL-encoded
          - added_during_sprint=<sprint name>
          - types=<types, separated by commas>: possible types are Issue types
        END
        get do
          sprint_name = params[:sprint_name]

          # Filtering
          filter = params.slice :sprint_name, :added_during_sprint
          filter[:types] = params[:types].split(',').map(&:strip) if params[:types]

          issues = Filter.apply(filter)

          if sprint_name
            statistics = Sprint.statistics_from_issues(issues, sprint_name)
          else
            # @todo calculate non-sprint-related statistics
            statistics = {}
          end

          {
            statistics: statistics,
            entries: issues
          }
        end

        params do
          requires :key, type: String, desc: 'Issue\'s key'
        end
        route_param :key do
          get do
            Operations::IssueData.get(key: params[:key])
          end
        end
      end

      resource :sprints do

        desc <<-END
        Return basic information on all sprints.
        Sprints are sorted by descending "started_at"
        date.

        @return [Array] sprint objects, each object contains
          the following attributes:
            - name
            - started_at
            - ended_at
            - state
        END
        get do
          Analyze::Sprint.all
        end

        params do
          requires :name, type: String, desc: 'Sprint name'
        end
        route_param :name do
          get do
            Analyze::Sprint.details params[:name]
          end
        end
      end

      resource :periods do

        desc <<-END
        Return the list of periods supported by the request
        taking a 'period' parameter.

        @return [Array] period objects, each object contains
          the following attributes:
            - identifier
            - name
        END
        get do
          Period.all
        end
      end

      resource :worklogs do

        desc <<-END
        Return the worklog items for the specified
        period.

        @return [Array] worklog objects, each object contains
          the following attributes:
            - TO BE COMPLETED
        END
        params do
          requires :period, type: String, desc: 'Search worklogs within a period returned by
            /api/periods'
        end
        get do
          from, to = Period.send params[:period]
          Search.worklogs_between from, to
        end
      end
    end
  end
end
