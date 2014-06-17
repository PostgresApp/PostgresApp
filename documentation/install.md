---
layout: documentation
title: Installing, Upgrading and Uninstalling Postgres.app
---

## Installing Postgres.app

To install Postgres.app, just drag it to your Applications folder and double click.

On first launch, Postgres will initialise a new database cluster and create a database for your username.
A few moments after launching, you should be able to click on "Open psql" to connect to the database.

If you'd like to use the command line tools delivered with Postgres.app, see the [section on Command Line Tools](cli-tools.html).

## Upgrading From A Previous Version

Starting with Version 9.2.2.0, Postgres.app is using semantic versioning, tied to the release of PostgreSQL provided in the release, with the final number corresponding to the individual releases of PostgresApp for each distribution.

Upgrading between bugfix versions (eg. 9.3.0.0 to 9.3.1.0, or 9.3.1.0 to 9.3.1.1) is as simple as replacing Postgres.app in your Applications directory. Make sure that the app is closed, though.

When updating between minor PostgreSQL releases (eg. 9.3.x to 9.4.x), Postgres.app will create a new, empty data directory.
You are responsible for migrating the data yourself.
We suggest using `pg_dumpall` to export your data, and then import it using `psql`.

Starting with Version 9.3.2.0, the default data directory is:
`~/Library/Application Support/Postgres/var-9.3`

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

Uninstall Postgres.app just like you would any application: quit, drag to the Trash, and Empty Trash.

Postgres.app data and configuration resides at `~/Library/Application\ Support/Postgres`, so remove that when uninstalling, or if you need to do a hard reset on the database.
