# How to deploy

## On Heroku

```
# Create a .env file with appropriate values
cp .env.example .env.production
edit .env.production

# Create the Heroku application and add mandatory plugins
heroku create
heroku addons:create heroku-postgresql:hobby-dev

# Add optional plugins (but recommended)
heroku addons:create papertrail:choklad

# Set environment variables
bin/set_env_production

# Deploy
bin/deploy

# Now perform a full sync
heroku run script/sync
```

## Synchronization

To keep the Agilizer's database synchronized, you must:

- Setup a JIRA webhook on the `/jira` endpoint (see doc/jira_webhook_setup.md for more details).
- Setup a scheduled job to run the `script/sync_jira` script (e.g. Heroku Scheduler plugin).
- Setup a scheduled job to run the `script/sync_toggl` script.
