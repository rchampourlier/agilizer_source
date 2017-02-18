# JIRA Webhook Setup

This tutorial assumes you deployed the AgilizerSource application under the https://example.com domain. This exposes an endpoint for the JIRA webhook at https://example.com/jira.

To setup the corresponding webhook, connect to your JIRA instance and go to the "System" page. In the menu on the left, click the "WebHooks" item.

Create a new webhook:

- URL: https://example.com/jira
- Events:
  - Issue related events
  - JQL: that's up to you
  - Selected events:
    - Issue: created, updated, deleted, worklog changed

Your application should now receive a webhook when an event happens and the issue should be updated in AgilizerSource!

**Tips**

- To check your webhook integration is working, generate an event and check your application logs.
- Or to test in development, use [ngrok](https://ngrok.com/).
