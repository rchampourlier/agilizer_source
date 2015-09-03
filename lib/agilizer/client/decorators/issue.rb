module Agilizer
  module Client
    module Decorators
      class Issue

        attr_reader :object

        def initialize(issue)
          @object = issue
        end

        def timespent_for_status(status)
          return nil if object.timespent_per_status.nil?
          item_for_status = object.timespent_per_status.find { |i| i['status'] == status }
          item_for_status ? item_for_status['timespent'] : nil
        end

        # DECORATOR PATTERN IMPLEMENTATION
        # TODO extract to superclass or module

        # Delegates missing instance methods to the source object.
        def method_missing(method, *args, &block)
          return super unless delegatable?(method)
          object.send(method, *args, &block)
        end

       # @private
       def delegatable?(method)
         object.respond_to?(method)
       end
      end
    end
  end
end
