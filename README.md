# Postgres.app

The easiest way to run PostgreSQL on your Mac

- Includes everything you need to get started with PostgreSQL
- Comes with a pretty GUI to start / stop servers
- Run Multiple Versions of PostgreSQL simultaneously

## Download

You can download recent versions of Postgres.app from the [Postgres.app website](http://postgresapp.com/).

Older versions and pre-releases are available in the releases section on GitHub.

## Documentation

Documentation is available at [http://postgresapp.com/documentation](http://postgresapp.com/documentation), as well as from the "Open Documentation" menu item in Postgres.app.

## What's Included?

- [PostgreSQL](http://www.postgresql.org/)
- [PostGIS](http://postgis.net/)
- [plv8](http://code.google.com/p/plv8js/wiki/PLV8)
- [wal2json](https://github.com/eulerto/wal2json)
- [pldebugger](https://git.postgresql.org/gitweb/?p=pldebugger.git)

## How To Build

Postgres.app consists of separate parts:

1) The PostgreSQL binaries, including extensions and a bunch of command line tools. 
   You can find the binaries in /Applications/Postgres.app/Contents/Versions

2) The Postgres.app user interface, written in Swift.
   This is the native Mac app that you see when you double click Postgres.app in the Finder.

For compatibility reasons we build the different parts on different versions of macOS.

- the binaries for PostgreSQL 9.4 - 10 are built on macOS 10.10 with Xcode 7.2.1

- the binaries for PostgreSQL 11 - 12 are built on macOS 10.12 with Xcode 8.3.3

- the binaries for PostgreSQL 13 are built on macOS 10.15 with Xcode 11.7

- the GUI is built on macOS 10.15 with Xcode 11.7

It is of course possible to use other versions of macOS / Xcode (see details below), but those are the environments we use.

### Building the GUI

If you want to work on the user interface only, you don't have to re-compile the binaries yourself.
By default, the buildscript for Postgres.app just copies the binaries from /Applications/Postgres.app/Contents/Versions

So just make sure you have a copy of Postgres.app in your applications folder.
Open the XCode file and start hacking!

Tools required for building the GUI:

- Xcode 11 or later (Swift 5 support is required)

### Building the Binaries

If you want to build your own versions of all the PostgreSQL binaries, you have slightly more work to do.

The directories src-10, src-11 and src-12 each contain a makefile that downloads and builds all the binaries.
If you have all the prerequisites installed (see below), you can just type `make`.

The makefile will download and build many gigabytes of sources. The default target (`all`) builds postgresql, postgis, plv8, and wal2json.
PostGIS and especially plv8 take a long time to build, so if you don't need them, type `make postgresql` instead.

The makefile will install all products in `/Applications/Postgres.app/Contents/Versions/xx` (xx is the major version of PostgreSQL).
So for best results, make sure that directory is empty before starting the build.

If you want to change the version number of any of the dependencies, edit the makefile (all version numbers are specified at the top).

You can use the `-j` option (eg. `make -j 3 postgresql`) for parallel builds.
My recommendation is to use one more job than the number of logical processors you have.
Since my macOS 10.12 VM is limited to 2 virtual CPUs, I use `-j 3`.
However, parallel builds make debugging problems a lot harder, so don't use them when something doesn't work.

Always check the exit code of make to see if any errors occurred, eg. `make -j 3 || echo "Build failed with exit code $?"` 

### Prerequisites for building the binaries

At the very least, you need the following:

- Xcode
- Developer Tools (install with `xcode-select -install`)

For building PostGIS, you also need

- autoconf
- automake
- pkgconfig (when building GDAL 3.0.0 or later)
- libtool

By default, PostgreSQL is built with documentation. To build the PostgreSQL 13 docs, you need these packages (see https://www.postgresql.org/docs/current/docguide-toolsets.html for details):

- docbook-xml-4.5
- docbook-xsl-nons
- fop

The quickest way to install all the dependencies is with MacPorts. Install MacPorts, then type:

    sudo port -N install autoconf automake pkgconfig libtool docbook-xml-4.5 docbook-xsl-nons fop

(The `-N` flag tells Macports to install required dependencies without asking)

Older versions required a different set of packages for building the docs, please see the specific versions of the documentation page https://www.postgresql.org/docs/current/docguide-toolsets.html for details.

It may also be possible to install those using homebrew, but I'm not sure if they have all the required packages.

## Under the Hood

Postgres.app bundles the PostgreSQL binaries inside the application package. When you first start Postgres.app, here's what it does:

- Initialise a database cluster: `initdb -D DATA_DIRECTORY -EUTF-8 --locale=XX_XX.UTF-8`
- Start the server: `pg_ctl start -D DATA_DIRECTORY -w -l DATA_DIRECTORY/postgres-server.log`
- Create a user database: `createdb USERNAME`

On subsequent app launches, Postgres.app only starts the server.

The default `DATA_DIRECTORY` is `/Users/USERNAME/Library/Application Support/Postgres/var-9.X`

Note that Postgres.app runs the server as your user, unlike other installations which might create a separate system user named `postgres`.

When you quit Postgres.app, it stops the server using the following command:

- `pg_ctl stop -w -D DATA_DIRECTORY`

## Command Line Utilities

Postgres.app also includes useful command line utilities (note: this list may be outdated):

- PostgreSQL: `clusterdb` `createdb` `createlang` `createuser` `dropdb` `droplang` `dropuser` `ecpg` `initdb` `oid2name` `pg_archivecleanup` `pg_basebackup` `pg_config` `pg_controldata` `pg_ctl` `pg_dump` `pg_dumpall` `pg_receivexlog` `pg_resetxlog` `pg_restore` `pg_standby` `pg_test_fsync` `pg_test_timing` `pg_upgrade` `pgbench` `postgres` `postmaster` `psql` `reindexdb` `vacuumdb` `vacuumlo`
- PROJ.4: `cs2cs` `geod` `invgeod` `invproj` `nad2bin` `proj`
- GDAL: `gdal_contour` `gdal_grid` `gdal_rasterize` `gdal_translate` `gdaladdo` `gdalbuildvrt` `gdaldem` `gdalenhance` `gdalinfo` `gdallocationinfo` `gdalmanage` `gdalserver` `gdalsrsinfo` `gdaltindex` `gdaltransform` `gdalwarp` `nearblack` `ogr2ogr` `ogrinfo` `ogrtindex` `testepsg`
- PostGIS: `pgsql2shp` `raster2pgsql` `shp2pgsql`

See [the documentation](http://postgresapp.com/documentation) for more info.

## Using the debugger

First, you'll need to adjust the configuration file (`postgresql.conf`) to preload the debugger extension. Add the following line:

```
shared_preload_libraries = 'plugin_debugger'
```

After you've saved this file, restart the server. You'll need to load the debugger extension into the database you wish to debug using:

```
CREATE EXTENSION pldbgapi;
```

Debugging requires that you are a superuser. Please refer to the [documentation](https://www.pgadmin.org/docs/pgadmin4/latest/debugger.html) for further information. This requires that you use a supported client, such as [PgAdmin 4](https://www.pgadmin.org/). The official documentation for the module can be accessed [here](https://git.postgresql.org/gitweb/?p=pldebugger.git;a=blob_plain;f=README.pldebugger;hb=HEAD).

## Contact

If you find a bug, please [open an issue](https://github.com/PostgresApp/PostgresApp/issues).

Postgres.app is maintained by [Jakob Egger](https://github.com/jakob).


## License

Postgres.app is released under the PostgreSQL License. See LICENSE for additional information.
