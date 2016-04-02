---
layout: documentation
title: Installing, Upgrading and Uninstalling Postgres.app
---

## Installing Postgres.app

To install Postgres.app, just drag it to your Applications folder and double click.

On first launch, Postgres will initialise a new database cluster and create a database for your username.
A few moments after launching, you should be able to click on "Open psql" to connect to the database.

If you'd like to use the command line tools delivered with Postgres.app, see the [section on Command Line Tools](cli-tools.html).

### Installation Directories

- Binaries: `/Applications/Postgres.app/Contents/Versions/9.3/bin`
- Headers: `/Applications/Postgres.app/Contents/Versions/9.3/include`
- Libraries: `/Applications/Postgres.app/Contents/Versions/9.3/lib`
- Default data directory: `~/Library/Application Support/Postgres/var-9.3`

## Upgrading From A Previous Version

PostgreSQL releases a major new version approximately once a year. Major releases are denoted by increasing the second digit of the version number (eg. PostgreSQL version 9.4 to 9.5). Minor updates are released every quarter (eg. 9.5 to 9.5.1).

The version number of Postgres.app corresponds to the version of PostgreSQL included in the package. For example, Postgres.app 9.5.2 contains PostgreSQL 9.5.2. If a new build with the same version of PostgreSQL inside becomes necessary (eg. a security issue in OpenSSL), a 4th digit is added (so Postgres.app 9.5.2.1 would be an newer build with the same version of PostgreSQL).

The data format always stays the same for minor versions. **To upgrade from a minor version to the next, you can just replace Postgres.app in your application directory.** In rare cases you might need perform additional steps such as reindexing -- please refer to the PostgreSQL release notes for details.

**When updating to a major new release (eg. 9.4 to 9.5), Postgres.app will create a new, empty data directory**, and leave the old one alone. You are responsible for migrating the data yourself. There are two ways to migrate the data:

### Migrate data using `pg_dump`

This is the recommended way to migrate your data.

1. While the old version of Postgres.app is running, use `psql --list` to show the list of databases
1. For each database you want to migrate use `pg_dump database_name > database_name.sql` to create a dump of your database
1. If you have roles and/or tablespaces you need to keep, use `pg_dumpall --globals-only > globals.sql`
1. Quit the old version of Postgres.app, then start the new version of Postgres.app
1. If you created globals.sql, use `psql -f globals.sql`
1. For each database, use `psql --command="create database database_name"` to create the database
1. For each database, use `psql -d database_name -f database_name.sql` to restore from the backup
1. Once you've tested everything is working, remove the old data at `~/Library/Application Support/Postgres`


### Migrate data using `pg_upgrade`

Using `pg_upgrade` from the command line is a bit more difficult.
This is recommended only if you have a large database and using `pg_dump` is too slow or uses too much disk space.
Make sure you completely understand the process and have a working backup before attempting this!

Since `pg_upgrade` needs the old and new binaries, you must make a special version of Postgres.app containing both the old and new binaries. For example, when upgrading from 9.4 to 9.5:

1. Quit the running Postgres.app
2. Right-Click to "Show Package Contents" on the old Postgres.app
3. Right-Click to "Show Package Contents" on the new Postgres.app
4. Copy the folder `Contents/Versions/9.4` from the old Postgres.app into `Contents/Versions` from the new Postgres.app
5. Place the modified new version inside the Applications folder (you need to do this and _not_ place both apps side by side, as the binaries in both versions expect to be located under `/Applications/Postgres.app`)
6. Go to `~/Library/Application Support/Postgres` and remove the `var-9.5` folder if it exists. Make an empty folder named `var-9.5`
7. In the terminal, create a new database cluster with `/Applications/Postgres.app/Contents/Versions/9.5/bin/initdb -D ~/Library/Application\ Support/Postgres/var-9.5 --encoding=UTF-8 --locale=en_US.UTF-8`
8. Finally, run the upgrade with `/Applications/Postgres.app/Contents/Versions/9.5/bin/pg_upgrade -b /Applications/Postgres.app/Contents/Versions/9.4/bin -B /Applications/Postgres.app/Contents/Versions/9.5/bin -d ~/Library/Application\ Support/Postgres/var-9.4 -D ~/Library/Application\ Support/Postgres/var-9.5 -v` (see the [pg_upgrade documentation](http://www.postgresql.org/docs/current/static/pgupgrade.html) for details)
9. `pg_upgrade` will leave behind two scripts, `analyze_new_cluster.sh` and `delete_old_cluster.sh`. Run them to optimise the new database and remove the old database cluster

## Uninstalling Postgres.app

1. Quit Postgres.app
2. Drag Postgres.app to the Trash
3. Delete the data directory (default location: `~/Library/Application Support/Postgres`)

