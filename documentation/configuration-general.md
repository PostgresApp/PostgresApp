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

### Connection security
Postgresql (and Postgres.app) default to only localhost connections, configurable by [listen_addresses](http://www.postgresql.org/docs/current/static/runtime-config-connection.html) –  'The default value is localhost, which allows only local TCP/IP "loopback" connections to be made'.

## Useful Directories

- Default data directory: `~/Library/Application\ Support/Postgres/var-9.5`
- Binaries: `/Applications/Postgres.app/Contents/Versions/9.5/bin`
- Headers: `/Applications/Postgres.app/Contents/Versions/9.5/include`
- Libraries: `/Applications/Postgres.app/Contents/Versions/9.5/lib`
- Man pages: `/Applications/Postgres.app/Contents/Versions/9.5/share`

