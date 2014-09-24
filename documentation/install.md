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

When updating between minor PostgreSQL releases (eg. 9.3.x to 9.4.x), Postgres.app will create a new, empty data directory. You are responsible for migrating the data yourself. Instructions for how to do this with the `pg_upgrade` utility can be found [in the PostgreSQL manual](http://www.postgresql.org/docs/current/static/pgupgrade.html).


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

