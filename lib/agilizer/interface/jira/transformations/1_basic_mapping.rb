require 'hash_op/mapping'

module Agilizer
  module Interface
    module Jira
      module Transformations

        # Applies the mapping defined by config/mapping.json
        # to the source data, using `HashOp::Mapping`.
        #
        module BasicMapping

          # @param source_data [Hash]
          # @param _processing_data [Hash] ignored by this transformation
          def run(source_data, _processing_data = nil)
            mapped_data = HashOp::Mapping.apply_mapping source_data, mapping
            { 'source' => 'jira' }.merge(mapped_data)
          end
          module_function :run

          # IMPLEMENTATION

          # Returns the mapping to be used, loading it
          # from `config/mapping.json`
          #
          # NB: this mapping is a custom mapping for a given JIRA instance
          #   and **will not** be adapted for other projects. You **must**
          #   ajust it according to your project. In particular for fields
          #   with `customfield` in the path.
          #
          # TODO add mapping injection
          def mapping
            {
              'identifier'             => { path: 'key' },
              'created_at'             => { path: 'fields.created', type: :time },
              'updated_at'             => { path: 'fields.updated', type: :time },
              'project_name'           => { path: 'fields.project.name' },
              'project_key'            => { path: 'fields.project.key' },
              'status'                 => { path: 'fields.status.name' },
              'resolved_at'            => { path: 'fields.resolutiondate' },
              'priority'               => { path: 'fields.priority.name' },
              'summary'                => { path: 'fields.summary' },
              'description'            => { path: 'fields.description' },
              'type'                   => { path: 'fields.issuetype.name' },
              'timespent'              => { path: 'fields.timespent' },
              'time_original_estimate' => { path: 'fields.timeoriginalestimate' },
              'time_estimate'          => { path: 'fields.timetracking.remainingEstimateSeconds' },
              'labels'                 => { path: 'fields.labels' },
              'category'               => { path: 'fields.customfield_10400.value' },
              'assignee'               => { path: 'fields.assignee.name' },
              'developer'              => { path: 'fields.customfield_10600.key' },
              'reviewer'               => { path: 'fields.customfield_10601.key' },

              'fix_versions'  => {
                path: 'fields.fixVersions',
                type: :array,
                item_mapping: {
                  type: :mapped_hash,
                  mapping: {
                    'name'      => { path: 'name' },
                    'date'      => { path: 'releaseDate' },
                    'released'  => { path: 'released' }
                  }
                }
              },

              'sprints' => {
                path: 'fields.customfield_10007',
                type: :array,
                item_mapping: {
                  type: :parseable_string,
                  parsing_mapping: {
                    'name' =>       { regexp: 'name=([^,]*),' },
                    'started_at' => { regexp: 'startDate=([^,]*),', type: :time },
                    'ended_at' =>   { regexp: 'endDate=([^,]*),', type: :time },
                    'state' =>      { regexp: 'state=([^,]*),' }
                  }
                }
              },

              'worklogs' => {
                path: 'fields.worklog.worklogs',
                type: :array,
                item_mapping: {
                  type: :mapped_hash,
                  mapping: {
                    'author' => { path: 'author.key' },
                    'timespent' =>  { path: 'timeSpentSeconds' },
                    'started_at' => { path: 'started', type: :time },
                    'created_at' => { path: 'created', type: :time }
                  }
                }
              }
            }
          end
          module_function :mapping
        end
      end
    end
  end
end
