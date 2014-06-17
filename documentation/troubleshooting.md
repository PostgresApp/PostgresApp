---
layout: documentation
title: Troubleshooting
---

### When Postgres.app says "Could not start on Port 5432"

This error message means that PostgreSQL server failed to start for some reason.
For debugging, it is often useful to try starting the server manually:

1. Check in preferences what your data directory is<br>(default: `/Users/USERNAME/Library/Application Support/Postgres/var-9.3`)
2. Quit Postgres.app
3. Open the Terminal and type `/Applications/Postgres.app/Contents/Versions/9.3/bin/postgres -D "DATA_DIRECTORY"` (replace DATA_DIRECTORY with your data directory, make sure to include the quotes because the path might contain spaces)
4. Now you should see a more detailed error message why the server failed to start

### Resetting Postgres.app

If you somehow mess up your Postgres.app installation, here's how to start fresh:

1. Quit Postgres.app
2. Open Activity Monitor, see if any processes name `postgres` are running. If so, kill them.
3. Delete the Folder `~/Library/Application Support/Postgres`
4. Open Postgres.app again
5. Wait a few moments before clicking "Open psql", initialising the database might take a few seconds

### Technical Support

If you run into any issues using Postgres.app, your first stop should be the [issue tracker](https://github.com/postgresapp/postgresapp/issues) on Github.
You can also ask [@Postgresapp](https://twitter.com/Postgresapp) on Twitter.
