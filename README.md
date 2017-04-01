# Agilizer Source

[![Build Status](https://travis-ci.org/jobteaser/agilizer_source.svg?branch=master)](https://travis-ci.org/jobteaser/agilizer_source)
[![Test Coverage](https://codeclimate.com/repos/58cd572875a7ea0451000451/badges/9fbf2df5b14046b201be/coverage.svg)](https://codeclimate.com/repos/58cd572875a7ea0451000451/coverage)
[![Code Climate](https://codeclimate.com/repos/58cd572875a7ea0451000451/badges/9fbf2df5b14046b201be/gpa.svg)](https://codeclimate.com/repos/58cd572875a7ea0451000451/feed)

## About

### What is Agilizer?

Agilizer is a suite of tools (Source, Notebooks...) which is intended for
providing data for Agile team efficiency and velocity measuring.

It is currently customized for the JobTeaser Tech team and supports the
following data sources:

- JIRA: project management
- Toggl: worklog reports

### What is the Source component?

This part is intended on fetching data from a project management solution 
and process them to enable using them with the other components of the suite 
(e.g. the UI).

## Prerequisites

Create a `.env` file to setup required environment variables (see `.env.example`). 
Once this is done, you should be able to play with:

```
bundle install
bin/console
```

## Getting started

### DB migration

```
bin/db/migrate
```

### Initial import

```
# DATE is a Ruby-parseable date. Toggl reports will be fetched
# from this date.
script/import DATE
```

### Reprocess all issues cached in JiraCache store

```
script/process_cache
```

### Cleanup Agilizer issues and get a fresh update from JiraCache store

```
script/clear_agilizer
script/sync
script/process_cache
```

## Documentation

Have a look to the documentation in [doc](//doc) for information on deployment, JIRA webhook configuration and the synchronization strategies.

## Troubleshooting

### Refreshing cached issue

```
jira_client_options = {
  domain: ENV['JIRA_DOMAIN'],
  username: ENV['JIRA_USERNAME'],
  password: ENV['JIRA_PASSWORD'],
  logger: Logger.new(STDOUT)
}
Agilizer::Interface::JIRA.import_issue(issue_key, jira_client_options)
```

## Understanding

### Definitions

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
