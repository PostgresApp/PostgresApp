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

- Binaries: `/Applications/Postgres.app/Contents/Versions/latest/bin`
- Headers: `/Applications/Postgres.app/Contents/Versions/latest/include`
- Libraries: `/Applications/Postgres.app/Contents/Versions/latest/lib`
- Default data directory: `~/Library/Application Support/Postgres/var-9.5`

## Upgrading From A Previous Version

PostgreSQL releases a major new version approximately once a year. Major releases are denoted by increasing the second digit of the version number (eg. PostgreSQL version 9.5 to 9.6). Minor updates are released every quarter (eg. 9.5 to 9.5.1).

The version number of Postgres.app corresponds to the version of PostgreSQL included in the package. For example, Postgres.app 9.5.2 contains PostgreSQL 9.5.2. If a new build with the same version of PostgreSQL inside becomes necessary (eg. a security issue in OpenSSL), an additional digit is added (so Postgres.app 9.5.2.1 would be an newer build with the same version of PostgreSQL).

The data format always stays the same for minor versions. **To upgrade from a minor version to the next, you can just replace Postgres.app in your application directory.** In rare cases you might need perform additional steps such as reindexing -- please refer to the PostgreSQL release notes for details.

**When updating to a major new release (eg. 9.5 to 9.6), Postgres.app will create a new, empty data directory**, and leave the old one alone. You are responsible for migrating the data yourself.

### Migrate data using `pg_dumpall`

1.	Make sure that the old version of Postgres.app is running
1.	Create a compressed SQL dump of your server (this could take some time):<br>
	`pg_dumpall --quote-all-identifiers | gzip >postgresapp.sql.gz`
1.  Quit the old version of Postgres.app, then start the new version of Postgres.app
1.	Now restore the SQL dump:<br>
	`gunzip <postgresapp.sql.gz | psql`

This method should work in most cases. However, if you have very large amounts of data,
or if you only want to migrate parts of your data, have a look at
some [alternative methods for migrating data](migrating-data.html).

## Uninstalling Postgres.app

1. Quit Postgres.app
2. Drag Postgres.app to the Trash
3. Delete the data directory (default location: `~/Library/Application Support/Postgres`)
