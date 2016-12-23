---
layout: documentation
title: Troubleshooting
---

## Troubleshooting & Support

### Common errors

The following list contains all errors which may occur while you're using Postgres.app.  

#### The binaries for this PostgreSQL server were not found

Postgres.app includes the PostgreSQL binaries inside the application package.
By default, PostgreSQL version 9.5 and 9.6 are included.

This error means that the binaries for this server were not found. 
This could happen if a future version of Postgres.app drops does not include your version of PostgreSQL anymore.
It could also happen if you manually added older binaries to Postgres.app, and then you updated Postgres.app.

To fix this issue, make sure that the correct binaries for your server are in `/Applications/Postgres.app/Contents/Versions/`

#### Port [number] is already in use

This error usually means that you already have a PostgreSQL server running on your Mac. 
Uninstall the old PostgreSQL server first, then start Postgres.app again.

It can also happen when a different user on your Mac is already running Postgres.app.
Only a single server can run on each port.

If you want to use multiple PostgreSQL servers simultaneously, configure them to use a different port.

#### There is already a PostgreSQL server running in this data directory
This can happen if you've configured Postgres.app to use a data directory that is used by a different PostgreSQL installation.
Stop the other server before starting Postgres.app.
In general, it is not recommended to just use a data directory created by another version of PostgreSQL, since it might have been configured differently.

#### The data directory contains an old postmaster.pid file / The data directory contains an unreadable postmaster.pid file
PostgreSQL puts a file named `postmaster.pid` in the data directory to store the process id of the PostgreSQL server process.
If PostgreSQL crashes, this file can contain an old pid that confuses PostgreSQL.
You can fix this issue by deleting the `postmaster.pid` file. However, you must make sure that PostgreSQL is really not running.
Open Activity Monitor and make sure that there are no processes named 'postgres' or 'postmaster'.

If you delete the `postmaster.pid` file while PostgreSQL is running, bad things will happen.


#### Could not initialize database cluster
This error means that the `initdb` command failed.
This should not happen. If it does, please open an issue on Github.
For troubleshooting, try executing the following command manually:

    /Applications/Postgres.app/Contents/Versions/latest/bin/initdb -D "DATA DIRECTORY" -U postgres --encoding=UTF-8 --locale=en_US.UTF-8



#### Could not create default user  / Could not create user database
After the data directory is initialized, Postgres.app creates a default user and database.
This error means that creating the user has failed. Check the server log (inside the data directory) for details.

You can try creating a default user and database manually:

    /Applications/Postgres.app/Contents/Versions/latest/bin/createuser -U postgres -p PORT --superuser USERNAME
    /Applications/Postgres.app/Contents/Versions/latest/bin/createdb -U USERNAME -p PORT DATABASENAME

Postgres.app uses your system user name for USERNAME and DATABASENAME by default.


#### File [or Folder] not found. It will be created the first time you start the server
Data directories and all its contents are only created when you start a server the first time.
This error occurs when you attempt to open a data directory (or file) which doesn't exist yet.
Start the server first and try again.

#### Unknown Error
This error should not occur.
Please open an issue on Github and provide a detailed description what lead to this error.



### Errors in the server log

The server log is inside the data directory in a file named `postgres-server.log`.

Here are some errors that could appear:

#### Could not create listen socket for "localhost"  
Usually this error is caused by broken `/etc/hosts` file.
The problem could be a missing `localhost` entry, syntax errors or incorrect whitespace.

For reference, here is what this file should look like by default on macOS:

	##
	# Host Database
	#
	# localhost is used to configure the loopback interface
	# when the system is booting.  Do not change this entry.
	##
	127.0.0.1	localhost
	255.255.255.255	broadcasthost
	::1             localhost 



#### database files are incompatible with server: The database cluster was initialized with PG_CONTROL_VERSION x, but the server was compiled with PG_CONTROL_VERSION y
This error usually happens when you try to start a server that was initialized with a prerelease version of PostgreSQL.
The on disk data format sometimes changes between pre-release versions.
You need to start the server with the version you initialized it with, then dump the database, then create a new server with the new version and restore.

### Errors when connecting to the PostgreSQL server

#### psql: FATAL: role "USERNAME" does not exist
By default, Postgres.app creates a PostgreSQL user with the same user as your system user name.
When this error occurs, it means that this user does not exist.
You can create it by executing the following command in the Terminal:

1. Make sure [your $PATH is configured correctly](cli-tools.html)
2. Execute the command `createuser -U postgres -s $USER`

- `-U postgres` tells createuser to connect with the `postgres` user name
- `-s` tells createuser to create a super user
- `$USER` is a variable containing your system user name, and tells createuser the name of the postgres user you want to create

#### psql: FATAL: database "USERNAME" does not exist
By default, psql tries to connect to a database with the same name as your local user.
This error means that this database does not exist. This can have several possible reasons:

- Postgres.app failed to create the default database when initializing the server
- You deleted the default database
- Your user name is different from the user name that initialized the server

There are multiple ways to fix this problem:

1. Make sure [your $PATH is configured correctly](cli-tools.html)
2. You can create the missing database using the command `createdb $USER`, or
3. You can connect to a different database, eg. `psql postgres` to connect to the other default database


#### Could not translate host name "localhost", service "5432" to address: nodename nor servname provided, or not known
Usually this error is caused by broken `/etc/hosts` file.
The problem could be a missing `localhost` entry, syntax errors or incorrect whitespace.

For reference, here is what this file should look like by default on macOS:

	##
	# Host Database
	#
	# localhost is used to configure the loopback interface
	# when the system is booting.  Do not change this entry.
	##
	127.0.0.1	localhost
	255.255.255.255	broadcasthost
	::1             localhost 

#### psql: FATAL:  could not open relation mapping file "global/pg_filenode.map": No such file or directory
This error can occur when you delete the data directory while the PostgreSQL server is still running.
To fix it, kill all PostgreSQL processes or restart your computer.
Then start a new PostgreSQL server.

### Starting the server manually

For debugging, it is often useful to try starting the server manually:

1. Quit Postgres.app
2. Open the Terminal and type `/Applications/Postgres.app/Contents/Versions/latest/bin/postgres -D "DATA DIRECTORY" -p PORT` (replace DATA DIRECTORY with your data directory, make sure to include the quotes because the path might contain spaces)
3. Now you should see a more detailed error message why the server failed to start

### Resetting Postgres.app

If you somehow mess up your Postgres.app installation, here's how to start fresh.  
***CAUTION: This will delete all your databases, tables and data!***

1. Quit Postgres.app
2. Open Activity Monitor, see if any processes name `postgres` are running. If so, kill them. Kill the process with the lowest pid first; child processes are respawned automatically after killing them.
3. Delete the Folder `~/Library/Application Support/Postgres`
4. Delete all settings using the command: `defaults delete com.postgresapp.Postgres2`
5. Open Postgres.app again

### Technical Support

If you run into any issues using Postgres.app, your first stop should be the [issue tracker](https://github.com/postgresapp/postgresapp/issues) on Github.
You can also ask [@PostgresApp](https://twitter.com/PostgresApp) on Twitter.

### Help others

If you encounter an issue and find a way to fix it, consider contributing to this documentation. This page is hosted on Github.