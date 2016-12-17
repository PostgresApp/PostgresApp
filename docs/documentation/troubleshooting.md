---
layout: documentation
title: Troubleshooting
---

### Make sure you run the latest version of Postgres.app

Check the GitHub [releases page](https://github.com/PostgresApp/PostgresApp/releases) to see if you have the latest version of Postgres.app.

### Check the server log

Postgresapp 9.3.5.1 and later keep a server log. The log is inside the data directory, named `postgres-server.log`.

### Try starting the server manually

For debugging, it is often useful to try starting the server manually:

1. Check in preferences what your data directory is<br>(default: `/Users/USERNAME/Library/Application Support/Postgres/var-9.3`)
2. Quit Postgres.app
3. Open the Terminal and type `/Applications/Postgres.app/Contents/Versions/9.3/bin/postgres -D "DATA_DIRECTORY"` (replace DATA_DIRECTORY with your data directory, make sure to include the quotes because the path might contain spaces)
4. Now you should see a more detailed error message why the server failed to start

### Resetting Postgres.app

If you somehow mess up your Postgres.app installation, here's how to start fresh:

1. Quit Postgres.app
2. Open Activity Monitor, see if any processes name `postgres` are running. If so, kill them. Kill the process with the lowest pid first; child processes are respawned automatically after killing them.
3. Delete the Folder `~/Library/Application Support/Postgres`
4. Open Postgres.app again
5. After a few moments a new database should be initialised

### Technical Support

If you run into any issues using Postgres.app, your first stop should be the [issue tracker](https://github.com/postgresapp/postgresapp/issues) on GitHub.
You can also ask [@PostgresApp](https://twitter.com/PostgresApp) on Twitter.

### Help others

If you encounter an issue and find a way to fix it, consider contributing to this documentation. This page is [hosted on GitHub](https://github.com/PostgresApp/postgresapp.github.io/tree/master/documentation). Fork it, improve it and send a pull request!
