---
layout: documentation
title: Using Command Line Tools with Postgres.app
---

## Tools provided by Postgres.app

The following tools come with Postgres.app:

- PostgreSQL: `clusterdb` `createdb` `createlang` `createuser` `dropdb` `droplang` `dropuser` `ecpg` `initdb` `oid2name` `pg_archivecleanup` `pg_basebackup` `pg_config` `pg_controldata` `pg_ctl` `pg_dump` `pg_dumpall` `pg_receivexlog` `pg_resetxlog` `pg_restore` `pg_standby` `pg_test_fsync` `pg_test_timing` `pg_upgrade` `pgbench` `postgres` `postmaster` `psql` `reindexdb` `vacuumdb` `vacuumlo`
- PROJ.4: `cs2cs` `geod` `invgeod` `invproj` `nad2bin` `proj`
- GDAL: `gdal_contour` `gdal_grid` `gdal_rasterize` `gdal_translate` `gdaladdo` `gdalbuildvrt` `gdaldem` `gdalenhance` `gdalinfo` `gdallocationinfo` `gdalmanage` `gdalserver` `gdalsrsinfo` `gdaltindex` `gdaltransform` `gdalwarp` `nearblack` `ogr2ogr` `ogrinfo` `ogrtindex` `testepsg`
- PostGIS: `pgsql2shp` `raster2pgsql` `shp2pgsql`

To use these tools, either call them using the full path like this:

```bash
$ /Applications/Postgres.app/Contents/Versions/9.4/bin/psql -h localhost
```

... but this is slightly inconvenient. It's better to add the bin directory to your path. Just add a line like the following to `.bash_profile`:

```bash
export PATH=$PATH:/Applications/Postgres.app/Contents/Versions/9.4/bin
```

If you're using the fish shell, add the following to your `config.fish` (normally located at `~/.config/fish/config.fish`):

```bash
set PATH /Applications/Postgres.app/Contents/Versions/9.4/bin $PATH
```

Once your path is correctly set up, you should be able to run `psql` without a host. You can check if the path is set up correctly by typing `which psql`.

## Man pages

Postgres.app ships with man pages. If you've configured your `PATH` as described above, just type `man psql` to read the official docs.

## System provided tools

`psql` is the PostgreSQL command-line interface to your database. Mac OS 10.7 and 10.8 ship with an older version of PostgreSQL, which can be started with the following command:

```bash
$ psql -h localhost
```
