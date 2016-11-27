module Agilizer
  module Interface
    module Jira

      # Functional module to transform data from JIRA issue
      # representation to Agilizer's.
      module Transformations

        # Process the passed data (source) and returns the processed
        # one.
        # Applies all transformations defined by the transformation
        # modules (see `::transformations` function) and return the
        # result of the last one.
        #
        # @param source_data [Hash] data to be processed
        # @return [Hash] the processed data
        def run(source_data)
          processing_data = nil
          transformations.each do |transformation_group|
            transformation_group.each do |transformation|
              processing_data = transformation.run(source_data, processing_data)
            end
          end
          processing_data
        end
        module_function :run

        # Returns the array of transformation modules to be applied
        # to the source data.
        #
        # Transformations are loaded from the `transformations` directory.
        # Each transformation module must implement a module function
        # `run(source_data, processing_data)` which returns the processed
        # data.
        #
        # The transformations are performed in order, prefixing the module's
        # file with a numeric index is advised to ensure proper processing
        # order.
        def transformations
          transformations_dir = File.expand_path('../transformations', __FILE__)
          groups = Dir[File.join(transformations_dir, '*.rb')].group_by do |file|
            File.basename(file)[/^(\d)+/, 1]
          end

          # We enforce sorting of the group indices since ordering
          # may be platform-dependent otherwise.
          groups = Hash[groups.sort]

          groups.values.collect do |files|
            files.collect do |file|
              require file
              module_name = File.basename(file)[/^(\d)+_(.*).rb$/, 2].camelize
              Transformations.const_get(module_name.to_sym)
            end
          end
        end
        module_function :transformations
      end
    end
  end
end
