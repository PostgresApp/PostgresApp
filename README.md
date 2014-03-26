# Postgres.app

Postgres.app is the easiest way to get started with PostgreSQL on the Mac. Open the app, and you have a PostgreSQL server ready and awaiting new connections. Close the app, and the server shuts down.

## Download

The latest version is available from the [Postgres.app website](http://postgresapp.com/).

Older versions and pre-releases are available in the releases section on github.

## Documentation

Documentation is available at [http://postgresapp.com/documentation](http://postgresapp.com/documentation), as well as from the "Open Documentation" menu item in Postgres.app.

## What's Included?

- [PostgreSQL 9.3.4](http://www.postgresql.org/docs/9.3/static/release-9-3-4.html)
- [PostGIS 2.1](http://postgis.net/)
- [plv8](http://code.google.com/p/plv8js/wiki/PLV8)

## How To Build

If you want to tweak the GUI only, just make sure you have a compiled copy of Postgres.app in your applications folder.
Open the XCode file and start hacking!

If you want to build your own versions of all the PostgreSQL binaries, you have a bit more work.

Make sure you have `autoconf`, `automake` installed. The quickest way to install them is using MacPorts:

    sudo port install autoconf automake

For building PostgreSQL with docs, you also need a bunch of other tools:

    sudo port install docbook-dsssl docbook-sgml-4.2 docbook-xml-4.2 docbook-xsl libxslt openjade opensp

Then make sure you remove other versions of `Postgres.app` from your Applications folder.

Open the `src` directory and type `make`.
This will download and build PostgreSQL, PostGIS, and PLV8. 
Several hundred megabytes of sources will be downloaded and built.
This can take an hour or longer, depending on your Internet connection and processor speed.
All the products will be installed in `/Applications/Postgres.app/Contents/MacOS/`.

Once this is done, you can just open `Postgres.xcodeproj` in Xcode, select the "Postgres" scheme, and click "Build".

To share your build, use the "Archive" command and then use the "Distribute" command in Organizer.

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

If you find a bug, please [open an issue](https://github.com/PostgresApp/PostgresApp/issues).

Postgres.app is maintained by [Jakob Egger](https://github.com/jakob) and [Craig Kerstiens](https://github.com/craigkerstiens).

Postgres.app was created by [Mattt Thompson](https://github.com/mattt).


## License

Postgres.app is released under the PostgreSQL License. See LICENSE for additional information.
