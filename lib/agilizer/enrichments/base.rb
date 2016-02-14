module Agilizer
  
  # Enrichments are post-processing operations that use the stored
  # issue data and enrich it. They are not expected to be performed
  # on a synchrone basis when the issue is created or updated since
  # they may require long processing time or rely on external services
  # (such as Github API).
  #
  # Enrichments must be independent from each other.
  module Enrichments
  end
end
