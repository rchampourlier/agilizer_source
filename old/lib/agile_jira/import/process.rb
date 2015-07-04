require 'hash_operations/hash_deep_access'
require 'hash_operations/hash_mapping'

require 'process/improve'
require 'process/enrich'
require 'process/extract'
require 'process/worklog'

module Agilizer

  # Process an external issue data to build an `Agilizer::Issue`.
  module Process

    # @param data [Hash] the issue data to build the essence
    #   from
    # @param improve [Bool] if false, the essence creation
    #   process is stopped after mapping, no improvement nor
    #   enrichment is done (optional, defaults to true)
    # @param enrich [Bool] if false, the essence is only the
    #   result of data mapping and improvement, but no
    #   enrichment is done.
    #
    # @return [Hash] the essence
    #
    # NB: the 'improve' and 'enrich' options are essentially
    #   for use in specs where we may only need a part of
    #   the improvements or enrichments to test their own
    #   implementation.
    def process(data, improve: true, enrich: true)
      result = map(data)
      result = improve(result, data) if improve
      result = enrich(result, data) if improve && enrich
      result
    end
    module_function :process

    def improve(mapped_data, data)
      result = Improve.set_worklog_time(mapped_data)
      result = Improve.add_simple_history(result, data)
      result
    end
    module_function :improve

    def enrich(essence, data)
      essence = Enrich.add_status_to_worklogs(essence, data)
      essence = Enrich.add_sprint_name_to_worklogs(essence, data)
      essence = Enrich.add_timespent_to_sprints(essence)
      essence = Enrich.add_timespent_per_status(essence)
      essence = Enrich.add_final_fix_version(essence)
      essence = Enrich.add_sprint_information(essence)
      essence
    end
    module_function :enrich
  end
end
