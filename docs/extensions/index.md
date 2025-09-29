---
layout: documentation
title: Postgres.app Extensions
---

## Bundled Extensions

Postgres.app comes with a lot of popular extensions:

- **Contrib Modules**: adminpack, amcheck, autoinc, bloom, btree_gin, btree_gist, citext, cube, dblink, dict_int, dict_xsyn, earthdistance, file_fdw, fuzzystrmatch, hstore, hstore_plpython3u, insert_username, intagg, intarray, isn, jsonb_plpython3u, lo, ltree, ltree_plpython3u, moddatetime, old_snapshot, pageinspect, pg_buffercache, pg_freespacemap, pg_prewarm, pg_stat_statements, pg_surgery, pg_trgm, pg_visibility, pg_walinspect, pgcrypto, pgrowlocks, pgstattuple, plpgsql, plpython3u, postgres_fdw, refint, seg, sslinfo, tablefunc, tcn, tsm_system_rows, tsm_system_time, unaccent, uuid-ossp, xml2
- **PostGIS**: postgis, postgis_raster, postgis_sfcgal, postgis_tiger_geocoder, postgis_topology, address_standardizer, address_standardizer_data_us
- pgrouting
- vector
- pljs
- **PL Debugger**: pldbgapi

For most extensions, all you need to do is to execute the SQL command `CREATE EXTENSION extension_name;`.

If you want to use PL/Python, you need to first install Python from [python.org](https://python.org).
See these [instructions](/documentation/plpython.html) for details.

For a full list of available extensions, please execute the SQL command `SELECT * FROM pg_available_extensions`

## Downloadable Extensions

Starting with PostgreSQL 18, we are providing some additional extensions for download.

These extensions need to be installed separately from the main app. To install them:

1. Download the extension installer package (.pkg)
2. Double click the .pkg to install it
3. Restart the PostgreSQL server
4. Now you can execute the commands `CREATE EXTENSION extension_name;` or `ALTER EXTENSION extension_name UPDATE;` to install or upgrade the extension in your database.

These extensions are compatible with Postgres.app 2.8.3 or later and PostgreSQL 18beta1:

- http: [http-pg18-1.6.3.pkg](https://github.com/PostgresApp/Extensions/releases/download/http-1.6.3/http-pg18-1.6.3.pkg)
- PL/v8: [plv8-pg18-3.2.3.pkg](https://github.com/PostgresApp/PostgresApp/releases/download/v2.8.3/plv8-pg18-3.2.3.pkg)
- pg_parquet:
	- [pg_parquet-pg18-0.4.0.pkg](https://github.com/PostgresApp/Extensions/releases/download/pg_parquet-0.4.0/pg_parquet-pg18-0.4.0.pkg) for PostgreSQL 18beta1
	- [pg_parquet-pg18-0.4.0.pkg](https://github.com/PostgresApp/Extensions/releases/download/pg_parquet-0.4.0-18beta2/pg_parquet-pg18-0.4.0.pkg) for PostgreSQL 18beta2 and 18beta3


## Building extensions from source (PostgreSQL 18 and later)

You can also build extensions yourself.
If you are using PostgreSQL 18 or later, make sure to install them into Application Support.
Postgres.app automatically configures search paths for extensions found in subdirectories of `~/Library/Application Support/Postgres/Extensions/XX` (XX is the major PostgreSQL version).

### Step 1: Check your $PATH
First, make sure that your path is configured correctly:  
```sh
  which pg_config
```
This command should print `/Applications/Postgres.app/Contents/Versions/latest/bin/pg_config`

### Step 2: Build your custom extension and install it into Application Support

  Here is a sample script that builds an extension (Replace XX with whatever major version of PostgreSQL you are using):

  ```sh
  git clone git@github.com:theory/pg-envvar.git
  cd pg-envvar
  make
  make install prefix="$HOME/Library/Application Support/Postgres/Extensions/XX/local"
  ```

### Step 3: Restart PostgreSQL

Postgres.app configures extension search paths when the server is started. To make sure PostgreSQL can find your installed extension, stop and start the server in Postgres.app.

**Done!**  Now you can enable the extension with `CREATE EXTENSION` as usual.

## Building extensions from source (up to PostgreSQL 17)

PostgreSQL 17 load extensions only from the directories inside the application package.
You can still build and install them, but there are two things you need to consider:

1) Terminal.app needs permission to update applications. Otherwise you will get "Operation not permitted" errors when installing the extension. This permission can be granted in System Settings.

2) Updating Postgres.app removes extensions and you need to reinstall them after the update.
