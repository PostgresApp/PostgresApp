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

- Binaries: `/Applications/Postgres.app/Contents/MacOS/bin`
- Headers: `/Applications/Postgres.app/Contents/MacOS/include`
- Libraries: `/Applications/Postgres.app/Contents/MacOS/lib`
- Shared Libraries: `/Applications/Postgres.app/Contents/MacOS/share`
- Data: `~/Library/Containers/com.heroku.postgres/Data/Library/Application\ Support/Postgres/var`

## Upgrading From A Previous Version

Starting with Version 9.2.2.0, Postgres.app is using semantic versioning, tied to the release of PostgreSQL provided in the release, with the final number corresponding to the individual releases of Postgres.app for each distribution.

Upgrading between bugfix versions (e.g. `9.3.0.0` → 9.3.1.0 or `9.3.1.0` → `9.3.1.1`) is as simple as replacing Postgres.app in your Applications directory (just be sure to quit the app first, though).

When updating between minor PostgreSQL releases (eg. 9.3.x to 9.4.x), Postgres.app will create a new, empty data directory. You are responsible for migrating the data yourself. Instructions for how to do this with the `pg_upgrade` utility can be found [in the PostgreSQL manual](http://www.postgresql.org/docs/current/static/pgupgrade.html).

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

Uninstall Postgres.app just like you would any other application: quit, drag to the Trash, and then "Finder > Empty Trash...".

Postgres.app data and configuration reside at `~/Library/Containers/com.heroku.postgres/Data/Library/Application\ Support/Postgres/var`, so remove that after uninstalling.
