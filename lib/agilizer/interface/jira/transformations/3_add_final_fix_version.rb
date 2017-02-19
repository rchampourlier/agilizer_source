require 'hash_op/filter'

module Agilizer
  module Interface
    class JIRA
      module Transformations

        # Transformation adding the last fixVersion for the issue to
        # the `processing_data` into `final_fix_version`.
        module AddFinalFixVersion

          def self.run(_source_data, processing_data)
            versions = processing_data['fix_versions']
            final_version = HashOp::Filter.filter(versions, 'released' => true).last
            name = final_version ? final_version['name'] : nil
            processing_data.merge 'final_fix_version' => name
          end
        end
      end
    end
  end
end
