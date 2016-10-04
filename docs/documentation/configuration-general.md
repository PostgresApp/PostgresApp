---
layout: documentation
title: Configuring Settings for Postgres.app
---

## Included Packages

Each release of Postgres.app comes with the latest stable release of PostgreSQL, as well a few choice extensions. Here's a rundown of what's under the hood:

- [PostgreSQL](http://www.postgresql.org/)
- [PostGIS](http://postgis.refractions.net/)
- [plv8](http://code.google.com/p/plv8js/wiki/PLV8)

## Connection Parameters
- **Host:** localhost
- **Port:** 5432 (default)
- **User:** *your user name*
- **Password:** *blank*
- **Database:** *same as user name*

## Allowing Remote Connections
By default, PostgreSQL only allows connections from localhost, and requires no password.

If you want to connect to PostgreSQL from a different computer,
you need to change the `listen_address` parameter in the file `postgresql.conf`,
which you can find in your data directory (See [Connections and Authentication](http://www.postgresql.org/docs/current/static/runtime-config-connection.html) in the PostgreSQL documentation).

Additionally, you need to edit the [`pg_hba.conf`](http://www.postgresql.org/docs/current/static/auth-pg-hba-conf.html) file to configure which hosts can access the database.

Restart Postgres.app after changing these files.

## Useful Directories

- Default data directory: `~/Library/Application\ Support/Postgres/var-9.6`
- Binaries: `/Applications/Postgres.app/Contents/Versions/9.6/bin`
- Headers: `/Applications/Postgres.app/Contents/Versions/9.6/include`
- Libraries: `/Applications/Postgres.app/Contents/Versions/9.6/lib`
- Man pages: `/Applications/Postgres.app/Contents/Versions/9.6/share`
- Config: `~/Library/Application\ Support/Postgres/var-9.6/postgresql.conf`

