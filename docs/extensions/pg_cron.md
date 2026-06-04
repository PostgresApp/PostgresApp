---
layout: documentation
title: Using pg_cron with Postgres.app
---

## Using pg_cron with Postgres.app

The [pg_cron extension](https://github.com/citusdata/pg_cron) allows you to run periodic tasks in your database whenever the server is running!

Use cases could be automatically generating reports, cleaning up old data, or even periodically downloading new data using the http extension.

We are offering pg_cron as an additional download for Postgres.app.

### Installing pg_cron for Postgres.app

1. Download the pg_cron installer package from https://postgresapp.com/extensions/
2. Double click the package and go through all steps to install the extension
3. Find the `postgresql.conf` file for your server
   - open Postgres.app
   - click the "Server Settings…" button
   - find the "Config" file path and click "Show"
   - open the config file with your favorite text editor
4. Update configuration parameters:
   - add pg_cron to shared preload libraries, eg. `shared_preload_libraries = 'pg_cron'`
   - set the time zone: `cron.timezone = 'Europe/Vienna'`
   - tell the extension to use background workers: `cron.use_background_workers = on` (you can make it work without this setting, but you might run into issues with trust authentication)
5. Restart the PostgreSQL server
6. Connect to the `postgres` database eg using `psql -U postgres postgres`
7. Activate the extension: `CREATE EXTENSION pg_cron;`

Done! You can now schedule tasks with `cron.schedule()`

You can find the full setup instructions for pg_cron here: [github.com/citusdata/pg_cron#setting-up-pg_cron](https://github.com/citusdata/pg_cron#setting-up-pg_cron)