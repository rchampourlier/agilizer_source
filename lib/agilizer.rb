# Agilizer provides a datawarehouse service to store
# data from bug and issue trackers in an homogeneous
# format, providing several services on this data:
#   - analytics,
#   - monitoring and alerting,
#   - etc.
module Agilizer
  VERSION = File.read(File.expand_path('../../VERSION', __FILE__)).strip

  Error = Class.new(StandardError)
end
