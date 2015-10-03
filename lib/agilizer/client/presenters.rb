module Agilizer
  module Client
    module Presenters

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
