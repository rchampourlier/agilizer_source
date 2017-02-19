# History

## 2017-02-19 - 0.2.2

- Updated to `jira_cache` 0.2.2 to enable fetching issues for all projects.

## 2017-02-19 - 0.2.1

- Minor fixes

## 2017-02-19 - 0.2.0

- Removed sprint-related fields and operations
- Updated for new custom fields

## 2017-02-18 - 0.1.0

- Updated `event_train` gem (was `event_bus`).
- Version bump: `0.1.0`

## 2016-12-13

- Finalized reworking a new version using PostgreSQL instead of MongoDB.

## 2015-09-03

### Objective

- Reopening the project after some time, ensuring it still works locally and on the deployed version.
- Checking its state, making sure it can be used for JobTeaser's Sprint Launch.

### Status

- Project is running locally, specs are green.
- Running `bin/sync` => got 4 errors:

```
E, [2015-09-03T06:39:19.282822 #33349] ERROR -- : Failed to write transformed data for JT-2408 (Waited 0.5 sec)
E, [2015-09-03T06:39:19.283430 #33349] ERROR -- : Failed to write transformed data for JT-1179 (Waited 0.5 sec)
E, [2015-09-03T06:39:19.289166 #33349] ERROR -- : ["/Users/rchampourlier/Dev/_personal/+agilizer/agilizer/lib/agilizer/interface/jira/notifier.rb:28:in `on_fetched_issue'", "/Users/rchampourlier/Dev/_personal/+agilizer/agilizer/lib/agilizer/interface/jira/notifier.rb:19:in `publish'", "/Users/rchampourlier/.rvm/gems/ruby-2.2.1@agilizer/bundler/gems/jira_cache-a17555d33fea/lib/jira_cache/client.rb:53:in `issue_data'", "/Users/rchampourlier/.rvm/gems/ruby-2.2.1@agilizer/bundler/gems/jira_cache-a17555d33fea/lib/jira_cache/sync.rb:32:in `sync_issue'", "/Users/rchampourlier/.rvm/gems/ruby-2.2.1@agilizer/bundler/gems/jira_cache-a17555d33fea/lib/jira_cache/sync.rb:78:in `block (2 levels) in fetch_issues'", "/Users/rchampourlier/.rvm/gems/ruby-2.2.1@agilizer/gems/thread-0.2.1/lib/thread/pool.rb:67:in `call'", "/Users/rchampourlier/.rvm/gems/ruby-2.2.1@agilizer/gems/thread-0.2.1/lib/thread/pool.rb:67:in `execute'", "/Users/rchampourlier/.rvm/gems/ruby-2.2.1@agilizer/gems/thread-0.2.1/lib/thread/pool.rb:405:in `block (2 levels) in spawn_thread'", "/Users/rchampourlier/.rvm/gems/ruby-2.2.1@agilizer/gems/thread-0.2.1/lib/thread/pool.rb:372:in `loop'", "/Users/rchampourlier/.rvm/gems/ruby-2.2.1@agilizer/gems/thread-0.2.1/lib/thread/pool.rb:372:in `block in spawn_thread'"]
E, [2015-09-03T06:39:19.291727 #33349] ERROR -- : ["/Users/rchampourlier/Dev/_personal/+agilizer/agilizer/lib/agilizer/interface/jira/notifier.rb:28:in `on_fetched_issue'", "/Users/rchampourlier/Dev/_personal/+agilizer/agilizer/lib/agilizer/interface/jira/notifier.rb:19:in `publish'", "/Users/rchampourlier/.rvm/gems/ruby-2.2.1@agilizer/bundler/gems/jira_cache-a17555d33fea/lib/jira_cache/client.rb:53:in `issue_data'", "/Users/rchampourlier/.rvm/gems/ruby-2.2.1@agilizer/bundler/gems/jira_cache-a17555d33fea/lib/jira_cache/sync.rb:32:in `sync_issue'", "/Users/rchampourlier/.rvm/gems/ruby-2.2.1@agilizer/bundler/gems/jira_cache-a17555d33fea/lib/jira_cache/sync.rb:78:in `block (2 levels) in fetch_issues'", "/Users/rchampourlier/.rvm/gems/ruby-2.2.1@agilizer/gems/thread-0.2.1/lib/thread/pool.rb:67:in `call'", "/Users/rchampourlier/.rvm/gems/ruby-2.2.1@agilizer/gems/thread-0.2.1/lib/thread/pool.rb:67:in `execute'", "/Users/rchampourlier/.rvm/gems/ruby-2.2.1@agilizer/gems/thread-0.2.1/lib/thread/pool.rb:405:in `block (2 levels) in spawn_thread'", "/Users/rchampourlier/.rvm/gems/ruby-2.2.1@agilizer/gems/thread-0.2.1/lib/thread/pool.rb:372:in `loop'", "/Users/rchampourlier/.rvm/gems/ruby-2.2.1@agilizer/gems/thread-0.2.1/lib/thread/pool.rb:372:in `block in spawn_thread'"]
```

- Ran `bin/process_cache`, no issue so data is up-to-date.
- Committed and deployed the latest version, everything seems working fine.
