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
- Shared Libraries: `/Applications/Postgres.app/Contents/Versions/9.3/share`
- Default data directory: `~/Library/Application Support/Postgres/var-9.3`

## Upgrading From A Previous Version

Starting with Version 9.2.2.0, Postgres.app is using semantic versioning, tied to the release of PostgreSQL provided in the release, with the final number corresponding to the individual releases of Postgres.app for each distribution.

Upgrading between bugfix versions (e.g. `9.3.0.0` → 9.3.1.0 or `9.3.1.0` → `9.3.1.1`) is as simple as replacing Postgres.app in your Applications directory (just be sure to quit the app first, though).

When updating between minor PostgreSQL releases (eg. 9.3.x to 9.4.x), Postgres.app will create a new, empty data directory. You are responsible for migrating the data yourself. There are two ways to migrate the data:

### Migrate data using `pg_dump`

This is the recommended way for migrating your data.

1. While the old version is running, use `pg_dump` (or `pg_dumpall` if you have multiple databases) to create a dump of your database
2. Quit the old version of Postgres.app, then start the new version of Postgres.app
3. Now use `psql` or `pg_restore` to restore the dump file

### Migrate data using `pg_upgrade`

Using `pg_upgrade` from the command line is a bit more difficult.
This is recommended only if you have a large database and using `pg_dump` is too slow or uses too much disk space.
Make sure you completely understand the process and have a working backup before attempting this!

Since `pg_upgrade` needs the old and new binaries, you must make a special version of Postgres.app containing both the old and new binaries. For example, when upgrading from 9.3 to 9.4:

1. Right-Click to "Show Package Contents" on the old Postgres.app
2. Right-Click to "Show Package Contents" on the new Postgres.app
3. Copy the folder `Contents/Versions/9.3` from the old Postgres.app into `Contents/Versions` from the new Postgres.app
4. Place the modified new version inside the Applications folder
5. Now use `pg_upgrade` according to the instructions [in the PostgreSQL manual](http://www.postgresql.org/docs/current/static/pgupgrade.html).
6. See [issue 241](https://github.com/PostgresApp/PostgresApp/issues/241) for details how to deal with migration errors.

## Removing Existing PostgreSQL Installations

For best results, you should remove any existing installation of PostgreSQL. Here's a run-down of the most common ways you may have installed it previously:

### Homebrew

``` bash
$ brew remove postgresql
````

### MacPorts

``` bash
$ sudo port uninstall postgres
```

### EnterpriseDB

In the EnterpriseDB installation directory, open `uninstall-postgresql.app`.

### Kyng Chaos

To uninstall the Kyng Chaos distribution, follow [these instructions](http://comments.gmane.org/gmane.comp.gis.postgis/32157).

## Uninstalling Postgres.app

1. Quit Postgres.app
2. Drag Postgres.app to the Trash
3. Delete the data directory (default location: `~/Library/Application Support/Postgres/var-9.3`)

