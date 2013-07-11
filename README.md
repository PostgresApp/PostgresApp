
# Postgres.app

Postgres.app is the easiest way to get started with PostgreSQL on the Mac. Open the app, and you have a PostgreSQL server ready and awaiting new connections. Close the app, and the server shuts down.

## Download

You can download the latest release from the [Postgres.app website](http://postgresapp.com/)

## Documentation

Documentation is available at [http://postgresapp.com/documentation](http://postgresapp.com/documentation), as well as from the "Open Documentation" menu item in Postgres.app.

## What's Included?

- [PostgreSQL 9.2.4](http://www.postgresql.org/docs/9.1/static/release-9-1-3.html)
- [PostGIS 2.0.3](http://postgis.refractions.net/)
- [plv8](http://code.google.com/p/plv8js/wiki/PLV8)

## How To Build

1. Open `Postgres.xcodeproj` in Xcode
2. Select the `Postgres` scheme
3. Click "Build"

XCode will download and build PostgreSQL, PostGIS, and PLV8. Several hundred megabytes of sources will be downloaded and built. This can take an hour or longer, depending on your Internet connection and processor speed.

If you want to build only PostgreSQL without extensions, select the Postgres project in the sidebar, then select the Postgres target, go to Build Phases, and remove the postgis and plv8 dependencies. This will make the build significantly faster.

## Under the Hood

Postgres.app bundles the PostgreSQL binaries as auxiliary executables. An [XPC service](http://developer.apple.com/library/mac/#documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingXPCServices.html) manages `postgres` processes, which are terminated when the app is quit.

The database data directory is located in the `/var` directory of the Postgres.app Container's Application Support directory. When the app is launched, it checks for "PG_VERSION" in the directory. If it does not exist, `initdb` is run, and later, `createdb` to create a default database for the current user.

## Command Line Utilities

Postgres.app also includes useful command line utilities:

- PostgreSQL: `clusterdb` `createdb` `createlang` `createuser` `dropdb` `droplang` `dropuser` `ecpg` `initdb` `oid2name` `pg_archivecleanup` `pg_basebackup` `pg_config` `pg_controldata` `pg_ctl` `pg_dump` `pg_dumpall` `pg_receivexlog` `pg_resetxlog` `pg_restore` `pg_standby` `pg_test_fsync` `pg_test_timing` `pg_upgrade` `pgbench` `postgres` `postmaster` `psql` `reindexdb` `vacuumdb` `vacuumlo`
- PROJ.4: `cs2cs` `geod` `invgeod` `invproj` `nad2bin` `proj`
- GDAL: `gdal_contour` `gdal_grid` `gdal_rasterize` `gdal_translate` `gdaladdo` `gdalbuildvrt` `gdaldem` `gdalenhance` `gdalinfo` `gdallocationinfo` `gdalmanage` `gdalserver` `gdalsrsinfo` `gdaltindex` `gdaltransform` `gdalwarp` `nearblack` `ogr2ogr` `ogrinfo` `ogrtindex` `testepsg`
- PostGIS: `pgsql2shp` `raster2pgsql` `shp2pgsql`

See [the documentation](http://postgresapp.com/documentation) for more info.

## Contact

Mattt Thompson

- http://github.com/mattt
- http://twitter.com/mattt
- mattt@heroku.com

## License

Postgres.app is released under the PostgreSQL License. See LICENSE for additional information.
