---
layout: documentation
title: Postgres.app Extensions
---

## Postgres.app Extensions

### Contrib Modules

These are optional extensions that are distributed together with PostgreSQL.

We include the following extensions with PostgreSQL 18:

adminpack, amcheck, autoinc, bloom, btree_gin, btree_gist, citext, cube, dblink, dict_int, dict_xsyn, earthdistance, file_fdw, fuzzystrmatch, hstore, hstore_plpython3u, insert_username, intagg, intarray, isn, jsonb_plpython3u, lo, ltree, ltree_plpython3u, moddatetime, old_snapshot, pageinspect, pg_buffercache, pg_freespacemap, pg_prewarm, pg_stat_statements, pg_surgery, pg_trgm, pg_visibility, pg_walinspect, pgcrypto, pgrowlocks, pgstattuple, plpgsql, plpython3u, postgres_fdw, refint, seg, sslinfo, tablefunc, tcn, tsm_system_rows, tsm_system_time, unaccent, uuid-ossp, xml2

For most extensions, all you need to do is to execute the SQL command `CREATE EXTENSION extension_name;`.

If you want to use PL/Python, you need to first install Python from [https://python.org](python.org).
See these [instructions](/documentation/plpython.html) for details.

### Bundled Extensions

We also include some 3rd party extensions with Postgres.app.

- PostGIS: postgis, postgis_raster, postgis_sfcgal, postgis_tiger_geocoder, postgis_topology, address_standardizer, address_standardizer_data_us
- pgrouting
- vector
- pljs
- pldbgapi (part of PL Debugger)

Just like contrib extensions, you can install these extensions in a database with the command `CREATE EXTENSION extension_name;`.

For a full list of available extensions, please execute the SQL command `SELECT * FROM pg_available_extensions`

### Unbundled Extensions

Starting with PostgreSQL 18, we are providing some additional extensions for download.

These extensions need to be installed separately from the main app. To install them:

1) Download the extension installer package (.pkg)
2) Double click the .pkg to install it
3) Restart the PostgreSQL server
4) Now you can execute the commands `CREATE EXTENSION extension_name;` or `ALTER EXTENSION extension_name UPDATE;` to install or upgrade the extension in your database.

#### Extensions for PostgreSQL 18beta1

These extensions are compatible with Postgres.app 2.8.3 or later.

- http: [http-pg18-1.6.3.pkg](https://github.com/PostgresApp/Extensions/releases/download/http-1.6.3/http-pg18-1.6.3.pkg)
- PL/v8: [plv8-pg18-3.2.3.pkg](https://github.com/PostgresApp/PostgresApp/releases/download/v2.8.3/plv8-pg18-3.2.3.pkg)
- pg_parquet: [pg_parquet-pg18-0.4.0.pkg](https://github.com/PostgresApp/Extensions/releases/download/pg_parquet-0.4.0/pg_parquet-pg18-0.4.0.pkg)


### Building other extensions

You can also build extensions yourself.
If you are using PostgreSQL 18 or later, make sure to install them into Application Support.

First, make sure that your path is configured correctly:

```sh
which pg_config
```

The result of this command should be /Applications/Postgres.app/Contents/Versions/latest/bin/pg_config

Here is a sample script that builds an extension (Replace 18 with whatever major version of PostgreSQL you are using):

```sh
git clone git@github.com:theory/pg-envvar.git
cd pg-envvar
make
make install prefix="$HOME/Library/Application Support/Postgres/Extensions/18/local"
```

Now restart the PostgreSQL server and you should be able to install the extension with `CREATE EXTENSION` as usual.

#### Building extensions for PostgreSQL 17 and earlier

PostgreSQL 17 load extensions only from the directories inside the application package.
You can still build and install them, but there are two things you need to consider:

1) Terminal.app needs permission to update applications. Otherwise you will get "Operation not permitted" errors when installing the extension

2) Updating Postgres.app removes extensions and you need to reinstall them after the update.