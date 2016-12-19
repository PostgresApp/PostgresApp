---
layout: documentation
title: Alternatives for migrating data when upgrading Postgres.app
---

## Migrating Data

When upgrading to a new major version of PostgreSQL, you need to migrate your data.
The easiest way to migrate your data is using pg_dumpall,
but there are alternative methods that can be useful
when you have very large databases,
or if you want to migrate only parts of the database.

### Migrate data using `pg_dumpall`

This is the easiest way to migrate your data. 

1.	Make sure that the old server is running
1.	Create a compressed SQL dump of your server (this could take some time):<br>
	`pg_dumpall --quote-all-identifiers | gzip >postgresapp.sql.gz`
1.  Stop the old server, then start the new server.
1.	Now restore the SQL dump:<br>
	`gunzip <postgresapp.sql.gz | psql`

### Migrate data using `pg_dump`

This method lets you select which databases you'd like to migrate.

1. While the old server is running, use `psql --list` to show the list of databases
1. For each database you want to migrate use `pg_dump database_name > database_name.sql` to create a dump of your database
1. If you have roles and/or tablespaces you need to keep, use `pg_dumpall --globals-only > globals.sql`
1. Stop the old server, then start the new server.
1. If you created globals.sql, use `psql -f globals.sql`
1. For each database, use `psql --command="create database database_name"` to create the database
1. For each database, use `psql -d database_name -f database_name.sql` to restore from the backup
1. Once you've tested everything is working, remove the old data from `~/Library/Application Support/Postgres`


### Migrate data using `pg_upgrade`

Using `pg_upgrade` from the command line is a bit more difficult.
This is recommended only if you have a large database and using `pg_dump` is too slow or uses too much disk space.
Make sure you completely understand the process and have a working backup before attempting this!

Since `pg_upgrade` needs the old and new binaries, you must make sure that Postgres.app contains the binaries of the old server and of the new server.
Postgres.app 2 contains 9.5 and 9.6 by default, but using other versions is possible as well.

Here's an example how to upgrade from 9.5 to 9.6:

1. Quit Postgres.app
2. Place the new version of Postgres.app in the /Applications folder
3. Right-Click to "Show Package Contents" on the new Postgres.app
4. Navigate to the subdirectory `Contents/Versions` and make sure that binaries for the old version and the new version are included.
5. If binaries are missing, copy them from a different version of Postgres.app (you can find all supported versions [on this page](all-versions.html))
6. Go to `~/Library/Application Support/Postgres` and create a new, empty folder for the new data directory, eg `var-9.6`
7. In the terminal, create a new database cluster with `/Applications/Postgres.app/Contents/Versions/9.6/bin/initdb -D ~/Library/Application\ Support/Postgres/var-9.6 --encoding=UTF-8 --locale=en_US.UTF-8`
8. Finally, run the upgrade with `/Applications/Postgres.app/Contents/Versions/9.6/bin/pg_upgrade -b /Applications/Postgres.app/Contents/Versions/9.5/bin -B /Applications/Postgres.app/Contents/Versions/9.6/bin -d ~/Library/Application\ Support/Postgres/var-9.5 -D ~/Library/Application\ Support/Postgres/var-9.6 -v` (see the [pg_upgrade documentation](http://www.postgresql.org/docs/current/static/pgupgrade.html) for details)
9. `pg_upgrade` will leave behind two scripts, `analyze_new_cluster.sh` and `delete_old_cluster.sh`. Run them to optimise the new database and remove the old database cluster
