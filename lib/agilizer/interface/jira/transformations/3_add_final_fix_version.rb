require 'hash_op/filter'

module Agilizer
  module Interface
    module Jira
      module Transformations

        # Transformation adding the last fixVersion for the issue to
        # the `processing_data` into `final_fix_version`.
        module AddFinalFixVersion

          def run(_source_data, processing_data)
            fix_versions = processing_data['fix_versions']
            final_fix_version = HashOp::Filter.filter(fix_versions, 'released' => true).last
            processing_data.merge 'final_fix_version' => final_fix_version
          end
          module_function :run
        end
      end
    end
  end
end
