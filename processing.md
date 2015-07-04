# Process data from source

## Issue -> Cumulated worklogs per assignee

- worklog_items: fields.worklog.worklogs
  * author: worklog_item.author.key
  * timespent: worklog_item.timeSpentSeconds

## Time period -> Cumulated worklogs per assignee

- search for Issue::Datum created after the start of the timeframe and updated before the end of the timeframe
