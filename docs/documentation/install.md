---
layout: documentation
title: Installing, Upgrading and Uninstalling Postgres.app
---

## Installing Postgres.app

To install Postgres.app, just drag it to your Applications folder and double click.

You can also start Postgres.app from other locations, but [some features may not work](relocation-warning.html).

To use command line tools (like `psql`) from your Terminal, add Postgres.app's bin folder to your `$PATH`:

You can do this with the following command: 

```bash
sudo mkdir -p /etc/paths.d && echo /Applications/Postgres.app/Contents/Versions/latest/bin | sudo tee /etc/paths.d/postgresapp
```

For more details, see the [section on Command Line Tools](cli-tools.html).

## Initializing a PostgreSQL server

By default, Postgres.app configures a server (cluster) with the latest supported version of PostgreSQL.
All you need to do is click the "Initialize" button.

A PostgreSQL server (cluster) can have multiple databases.
By default, Postgres.app creates a database with the same name as your user name.
You can create more databases using the `createdb` command line tool, or using the `CREATE DATABASE` SQL command.

Postgres.app allows running multiple PostgreSQL servers (clusters) on your Mac.
This is especially useful if you want to run multiple versions of PostgreSQL simultaneously.

To add a cluster, click the "+" icon in the sidebar.

## Protecting PostgreSQL with a password

The default settings for PostgreSQL allow any app on your computer to connect without a password ("trust" authentication).

To improve security, we recommend protecting all PostgreSQL servers with a password by enabling "scram-sha-256" authentication.

1. Stop the server
2. Change the authentication method
    1. Click the "Server Settings…" button
    2. Look for the HBA file and click "Show"
    3. Open the file in a text editor
    4. Replace `trust` with `scram-sha-256`
3. Change passwords (repeat for each user)
    1. Click the "Server Settings…" button
    2. Click the "Change Password…" button
    3. Pick a new password. Don't use your computer password.
4. Start the server again

(On PostgreSQL servers before version 14, use `md5` instead of `scram-sha-256`.)

After setting a password, the databases will no longer be shown in Postgres.app.

## Allowing Network Access

By default, PostgreSQL only allows connections from apps on your computer.
Follow these instructions to allow other computers on your network to connect.

1. Stop the server
2. Make sure you have a password configured (see above)
3. Change the listen address
    1. Click the "Server Settings…" button
    2. Find the config file and click "Show"
    3. Open the file in a text editor
    4. Find the `listen_addresses` setting, remove the leading `#`, and change the value from `'localhost'` to `'*'`.
4. Update the HBA file
    1. Click the "Server Settings…" button
    2. Look for the HBA file and click "Show"
    3. Open the file in a text editor
    4. At the bottom, add this line: `host all all 0.0.0.0/0 scram-sha-256` (allow secure authentication with a password for all databases and all users from all IPv4 addresses)
5. Start the server again

## Installing PostgreSQL extensions

Postgres.app includes a number of useful extensions.
Before you can use them, you need to install them in each database using the `CREATE EXTENSION` SQL command.

Postgres.app includes the following extensions:

- PostGIS
- pgRouting
- pgvector
- PL/Python [Instructions for PL/Python](plpython.html)
- PL/JS
- PL Debugger
- and most of the contrib extensions

For the full list, execute the SQL query `select * from pg_available_extensions;`

### Building custom PostgreSQL extensions

It is also possible to build custom PostgreSQL extensions for Postgres.app.

Typically, you just need to make sure the $PATH is configured correctly and that `pg_config` works, then you can build most extensions with `make && make install`.

The first time you do this, macOS will show that "Terminal tried to modify an application". This setting can be changed in System settings / Security.

However, this is an advanced topic and requires some familiarity with Unix build systems.

Installing custom extensions will break the code signature of Postgres.app. 
Currently, macOS verifies the code signature only the first time you launch an application, so as long as you launch Postgres.app before building custom extensions it should work.
However, this may change in a future version of macOS.

Custom extensions will be removed when updating Postgres.app, so build them again afterwards.

### Important Directories

- Binaries: `/Applications/Postgres.app/Contents/Versions/latest/bin`
- Headers: `/Applications/Postgres.app/Contents/Versions/latest/include`
- Libraries: `/Applications/Postgres.app/Contents/Versions/latest/lib`
- Default data directory: `~/Library/Application Support/Postgres/var-XX` (XX is the major version of PostgreSQL)

## Uninstalling Postgres.app

1. Quit Postgres.app (via the menu bar icon if shown) and drag it to the Trash
2. (Optional) Delete the data directories (default location: `~/Library/Application Support/Postgres`)
4. (Optional) Delete preferences for Postgres.app by executing the following command:  
   `defaults delete com.postgresapp.Postgres2`
5. (Optional) Remove the `$PATH` config for the command line tools:  
   `sudo rm /etc/paths.d/postgresapp`
