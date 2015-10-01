# Agilizer

[![Build Status](https://travis-ci.org/rchampourlier/agilizer.svg)](https://travis-ci.org/rchampourlier/agilizer)
[![Coverage Status](https://coveralls.io/repos/rchampourlier/agilizer/badge.svg?branch=master&service=github)](https://coveralls.io/github/rchampourlier/agilizer?branch=master)
[![Code Climate](https://codeclimate.com/github/rchampourlier/agilizer/badges/gpa.svg)](https://codeclimate.com/github/rchampourlier/agilizer)

Easy access to useful statistics for Agile teams. It is intended to work
with several project management solutions, but currently only JIRA is
supported.

## Use Cases

- List issues added to current sprint
- Detect workflow anomalies
  * Missing pull request in comment on an issue going for Review
- Detect staled issues
- Detect missing worklogs
- Calculate time added to current sprint
- Track issues picking order
- List changes on a specific day
- List worklogs for today
- Analyze worklogs per team member
- Detect issues with remaining estimate + timespent greater than original estimate
- Detect issues with remaining estimate increasing

_...and more!_

### Statistics

Get useful statistics about your project by looking at
your JIRA issues (with automation, like any good-and-lazy
developer!).

- Average time per status
- Average time per estimation point per status
- Average logged work per estimation point

### Alerts

Get an alert when an issue:
- is moving without work logged,
- is still in review after 1 week,
- ...

## Prerequisites

Create a `.env` file to setup required environment variables, for example:

```
AGILIZER_ENV=development
AGILIZER_MONGODB_URI=mongodb://127.0.0.1:27017/agilizer
AGILIZER_JIRA_DOMAIN=domain.atlassian.net
AGILIZER_JIRA_USERNAME=username
AGILIZER_JIRA_PASSWORD=password
AGILIZER_JIRA_LOG_LEVEL=DEBUG
```

Once this is good, you should be able to play with:

```
bundle install
bin/console
```

## Getting started

To reprocess all cached issues:

```
bin/process_cache
```

### Understanding

#### Definitions

**`Issue`**
The container class for source and processed issue data.

- `data`: source data from JIRA
- `essence`: results from performed mapping and processing on `data`

## Contributing

### How to add spec case fixtures

```
bin/build_spec_case ISSUE-KEY 1
```

This will generate the `spec/fixtures/jira_issues/case_1.json` file, assuming there is a `JiraCache::Issue` with the `ISSUE-KEY` key in the development database.

**Anonymization / post-processing**

You can perform custom post-processing (for example to anonymize your issue) by creating the `bin/build_spec_case_post_process` file (you can use `bin/build_spec_case_post_process_example` to get started).

### Rules

- Please respect the code style (run Rubocop with the rules defined in the project).
