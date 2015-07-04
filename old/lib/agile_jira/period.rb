module Agilizer

  # Provides easy methods to access a range of dates
  # corresponding to a human-readable period.
  #
  # A period is here an array of a start time and an
  # end time.
  #
  class Period
    @@period_identifiers = %i(
      today
      yesterday
      current_week
      last_week
      current_sprint
      last_sprint
      current_month
      last_month
    )

    def self.today
      [Date.today.beginning_of_day, Date.today.end_of_day]
    end

    def self.yesterday
      [Date.yesterday.beginning_of_day, Date.yesterday.end_of_day]
    end

    def self.current_week
      [Date.today.beginning_of_week, Date.today.end_of_week]
    end

    def self.last_week
      [Date.today.last_week.beginning_of_week, Date.today.last_week.end_of_week]
    end

    def self.current_sprint
      sprint = Sprint.current
      [sprint['started_at'], sprint['ended_at']]
    end

    def self.last_sprint
      sprint = Sprint.last
      [sprint['started_at'], sprint['ended_at']]
    end

    def self.current_month
      [ Time.now.beginning_of_month, Time.now.end_of_month ]
    end

    def self.last_month
      [ Time.now.prev_month.beginning_of_month, Time.now.prev_month.end_of_month ]
    end

    # @return [Array] hashes representing the available
    #   ranges, each hash contains:
    #     - identifier [String] the identifier to use
    #       in requests to represent this period
    #     - label [String] the label usable to present
    #       the period in an interface
    def self.all
      @@period_identifiers.map do |period_identifier|
        {
          identifier: period_identifier.to_s,
          label: period_identifier.to_s.humanize
        }
      end
    end
  end
end
