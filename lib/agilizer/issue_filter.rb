require 'agilizer/issue_analysis/sprints'

module Agilizer
  module IssueFilter

    def available_filter
      {
        sprint: {
          name: IssueAnalysis::Sprints.names,
          relative: %w(current)
        }
      }
    end

    def with_filter(filter)
      query = {}

      if filter[:sprint]
        if (relative_sprint = filter[:sprint][:relative])
          if !available_filter[:sprint][:relative].include?(relative_sprint)
            fail "Unknown relative sprint filter \"#{relative_sprint}\""
          end
          filter[:sprint][:name] = [IssueAnalysis::Sprints.send(:"#{relative_sprint}_sprint_name")]
        end
        if filter[:sprint][:name]
          item_query = { :$elemMatch => { name: { '$in' => filter[:sprint][:name] } } }
          query.merge! sprints: item_query
        end
      end

      # if filter[:added_during_sprint]
      #   item_query = { :$elemMatch => { :'name' => filter[:added_during_sprint], :'during_sprint.added' => true } }
      #   query.merge! :'essence.sprints' => item_query
      # end

      # if filter[:types]
      #   query.merge! :'essence.labels' => { :$}

      # if filter[:worklog]
      #   author = filter[:worklog][:author]
      #   status = filter[:worklog][:status]
      #   raise "worklog filter must specify both author and status values" if author.blank? or status.blank?
      #
      #   item_query = { :$elemMatch => { author: author, status: status } }
      #   query.merge! :'essence.worklogs' => item_query
      # end

      # Setting limit from params[:limit] or 100. Max is 100.
      limit = [(filter[:limit] || 100).to_i, 100].min

      self.where(query).limit(limit)
    end
  end
end
