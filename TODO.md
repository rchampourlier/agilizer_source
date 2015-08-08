# TODO

1. Board for sprint launch and realtime print status
  - Filter issues on a sprint
  - Calculate assigned estimate per developer
- Worklog reports (today, yesterday, current week, last week)
    `Process.Worklog.cumulate_per_author Analyze.worklogs_for_yesterday`
- Process: spec, test sprint value mapping
- HashMapping: conversion inside of parsing
- Sprints: Timespent per sprint for a given issue
    `Enrich.add_worklog_to_sprints Issue.find_by_key('JT-1130').data`
- Sprint/Analyze
  -> `Sprint.report('Sprint 2014-10-13')`
  - for each issue worked-on during the sprint
    (`Search.essences_for_sprint('Sprint 2014-10-13')`)
    - worklogs during the sprint
      -> timespent per author during the sprint
      -> cumulated timespent during the sprint
- Analyze/All sprints
  -> `Analyze::sprint_reports`
  - aggregate `Analyze::sprint` for all sprints
- Analyze: Issues added to the sprint
  - enriching essences with sprints.added_at/removed_at
  - add this information to `Sprint::issue_reports`
  - create `Sprint::report` to be used by `Analyze::sprints`
- Issue: timespent per status
- Period
  - current_sprint
  - last_sprint
- Basic interface for worklogs
- Enrich::add_sprint_information
  - Problem: how to calculate the real original estimate
    of a sprint when ongoing issues have been introduced?
    The original estimate of the issue is not the remaining
    estimate of the issue at the beginning of the sprint.
      => requires a deeper analysis of an issue when creating
         the issue's report for a sprint, taking changes to
         remaining estimate into account
- Currently, sprint reports estimates all issues that have been in the sprint at some time, not the one that were still in the sprint during the sprint period. We must only have issues that were in the sprint during the sprint period => this should have been fixed by ignoring the sprints identified within history only
- Check data:
  - `Agilizer::Analyze::Sprint.report 'Sprint 2014-12-02'`
  - `Issue.find_by_key('JT-1595')` => `time_estimate_at_sprint_end` seems wrong (different from `time_estimate` when the issue was processed)
- Enable glyphicons
- Add information on a JIRA at beginning/end of each sprint
  - Status
  - Time estimate
  - Time original estimate
- Enrich each worklog with issue information at time of log:
  - current sprint
  - status
- Add information on a JIRA at beginning/end of each sprint
  - Timespent
- Why not correct the worklogs when mapped so that the worklog start time is the worklog creation time minus the timespent? So that it "automatically" handles simultaneous changes in issue status and worklog addition, instead to have to apply corrections like done in Extract::timespent_per_status.
- Remove issue_reports from API's sprints/:name, replace by
  access through sprints/:name/issues
- Add statistics to sprints/:name/issues
- Report data:
  - estimate VS timespent per JIRA
- Visualize activity of the project
  * worklogs
  * issue moves
- Implement filter on API-side (with tests)
- Compare sprint information / scope against JIRA:
  https://jobteaser.atlassian.net/secure/RapidBoard.jspa?rapidView=12&projectKey=JT&view=reporting&chart=sprintRetrospective&sprint=38
- Interface: allow select of period using date selectors
- Correctly handle issues removed from a sprint, they are not associated
  to the sprint anymore:
    - do we count their worklogs in the sprint?
    - we don't track them as sprint scope changes
    - we should include in the essence a list of all sprint
      the issue was in at some point
- Analyze::Issue
  - determine issue category
    - from issue type, original estimate, labels
- Analyze::Sprint
  - ::report
    - statistics
      - on
        - count of issues
        - estimate
        - timespent
      - by
        - issue type
        - issue category
- Interface / Sprints
  - list of issues with status, current assignee
  - time since last change / status change
  - cumulated estimate of added JIRAs
  - total original estimate
  - total remaining estimate
- see the last worklogs for someone, the associated JIRAs details
- list of last worklogs
  - filterable on a period of time (by default last week)
  - filterable by author
  - access associated JIRA information
- on a sprint
  - timespent per label / label group / category (calculated from labels)
- Interface / Issues
  - ratio estimate / timespent, sortable
- Visualizations (Analyze):
  - timespent per author
  - sprint
    - progress
  - issue
    - progress
    - timespent per status
    - number of transitions back to development
- Analyze
  - average timespent per status per author compared to others
  - average ratio timespent / estimate per author compared to others
  - sorted list of issues on correctness of estimation
- Tests on API
- Alerts:
  - issues over estimation
  - issue status change without worklog
  - later:
    - issue changed to Ready for Release with PR not merged
- Who did what?
  - List of actions done by each person
  - In particular, be able to track the rank of each touched issue to identify failures to follow the first issue taken first.
- Essence: Detect Github's pull request(s)
- Syncing:
  - Find a way to have less issues updated when syncing
  - Prevent old history changes (JIRA may be removing old
  sprints information)
- Tests on #sync_project
- Extract sprint records from issue data when processing. Keep a single version of each sprint, only updating it if the processed issue is more recent that the sprint record. Link the sprint to the associated issues. Maybe this link can support remembering an issue was in a sprint at some time, then removed.
