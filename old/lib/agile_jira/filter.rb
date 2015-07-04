require 'issue'

module Agilizer

  # Apply filter among Issues
  module Filter

    # @param filter [Hash]
    def apply(filter)
      query = {}

      if filter[:sprint_name]
        item_query = { :$elemMatch => { :'name' => filter[:sprint_name] } }
        query.merge! :'essence.sprints' => item_query
      end

      if filter[:added_during_sprint]
        item_query = { :$elemMatch => { :'name' => filter[:added_during_sprint], :'during_sprint.added' => true } }
        query.merge! :'essence.sprints' => item_query
      end

      # if filter[:types]
      #   query.merge! :'essence.labels' => { :$}

      if filter[:worklog]
        author = filter[:worklog][:author]
        status = filter[:worklog][:status]
        raise "worklog filter must specify both author and status values" if author.blank? or status.blank?

        item_query = { :$elemMatch => { author: author, status: status } }
        query.merge! :'essence.worklogs' => item_query
      end

      search(query)
    end
    module_function :apply

    def search(query)
      Issue.where(query)
    end
    module_function :search
  end
end
