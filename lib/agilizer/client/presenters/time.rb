module Agilizer
  module Client
    module Presenters
      module Time

        # Transform seconds to "3.1h" for example
        def present(seconds)
          return 'nd' if seconds.nil?
          "#{(seconds / 3600.to_f).round(1)} h"
        end
        module_function :present
      end
    end
  end
end
