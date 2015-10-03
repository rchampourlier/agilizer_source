require 'agilizer/client/presenters'

module Agilizer
  module Client
    module Presenters

      # Presenter returning the input with no change.
      module Identity
        def present(value)
          value
        end
      end

      # Presenter to format time values.
      # Transform seconds to "3.1h" for example
      module Time
        def present(seconds)
          return 'nd' if seconds.nil?
          "#{(seconds / 3600.to_f).round(1)} h"
        end
        module_function :present
      end

      # Returns the appropriate Presenters' module according
      # to the specified type.
      #
      # @param type [Symbol] within :string, :time
      def for_type(type)
        case type
        when :string then Identity
        when :time then Time
        else fail ArgumentError, "Type #{type} is not supported."
        end
      end
      module_function :for_type
    end
  end
end
