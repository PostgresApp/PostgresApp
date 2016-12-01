---
layout: documentation
title: Troubleshooting
---

## Troubleshooting

### Common errors

The following list contains all errors which may occur while you're using Postgres.app.  

***The binaries for this PostgreSQL server were not found***  
Postgres.app needs several binary files to work. This error is thrown when one or more binaries are not found at the expected path.
To solve this error, create a new server and use the same port number and data directory as the broken server.

***Port [number] is already in use***  
The PostgreSQL server attempts to use a port, which is already in use by another server.
To solve this error, you can either use a different port or terminate the server which uses this port.

***There is already a PostgreSQL server running in this data directory***  
Each data directory can be only used by one server at the same time. This error occurs when you try to start a server,
which attempts to access a data directory which is already in use by another server. To proceed, you have to terminate the blocking server first.

***The data directory contains an old postmaster.pid file / The data directory contains an unreadable postmaster.pid file***  
Every PostgreSQL data directory contains a postmaster.pid file which contains the process id of the according server.
Open Activity Monitor, search for the process id in the postmaster.pid file and kill the affected process including its child processes.
Now, try again to start the server.

***Could not initialize database cluster / Could not create default user  / Could not create user database***  
When you attempt to start a new server the first time, Postgres.app creates a new database cluster, user und user database first.
This error means that something went wrong while creating the database cluster / default user / user database.
Create a new server and try again.

***File [or Folder] not found. It will be created the first time you start the server.***
Data directories and all its contents are only created when you start a server the first time.
This error occurs when you attempt to open a data directory (or file) which doesn't exist yet.
Start the server first and try again.

***Unknown Error***
This error should not occur.
Please let us know when you encounter this error and provide a detailed description what lead to this error.





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

If you run into any issues using Postgres.app, your first stop should be the [issue tracker](https://github.com/postgresapp/postgresapp/issues) on Github.
You can also ask [@PostgresApp](https://twitter.com/PostgresApp) on Twitter.

### Help others

If you encounter an issue and find a way to fix it, consider contributing to this documentation. This page is [hosted on Github](https://github.com/PostgresApp/postgresapp.github.io/tree/master/documentation). Fork it, improve it and send a pull request!
