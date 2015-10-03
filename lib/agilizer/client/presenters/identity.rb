require 'agilizer/client/presenters'

module Agilizer
  module Client
    module Presenters

      # Presenter returning the input with no change.
      module Identity
        def present(value)
          value
        end
        module_function :present
      end
    end
  end
end
