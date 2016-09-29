# How to deploy

## On Heroku

```
# Create a .env file with appropriate values
cp .env.example .env
edit .env

# Create the Heroku application and add mandatory plugins
heroku create
heroku addons:create mongolab:sandbox

# Add optional plugins (but recommended)
heroku addons:create papertrail:choklad

# Set environment variables
bin/set_env_production

# Deploy
bin/deploy

# Now perform a full sync
heroku run bin/sync
```

To keep the Agilizer's database synchronized, there are 2 options:

- setup a scheduled job to run the `bin/sync` script (using Heroku Scheduler plugin),
- configure a JIRA webhook on the `/jira` endpoint (provided by JiraCache, see more in `config.ru`).
