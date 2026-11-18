# Postgres.app

The easiest way to run PostgreSQL on your Mac

- Includes everything you need to get started with PostgreSQL
- Comes with a pretty GUI to start / stop servers
- Run multiple versions of PostgreSQL simultaneously

## Download

You can download recent versions of Postgres.app from the [Postgres.app website](http://postgresapp.com/).

Older versions and pre-releases are available in the releases section on GitHub.

## Documentation

Documentation is available at [http://postgresapp.com/documentation](http://postgresapp.com/documentation), as well as from the "Open Documentation" menu item in Postgres.app.

## What's Included?

- [PostgreSQL](http://www.postgresql.org/)
- [PostGIS](http://postgis.net/)
- [pgvector](https://github.com/pgvector/pgvector)
- [pgrouting](https://pgrouting.org) (PostgreSQL 18 and lower)
- [wal2json](https://github.com/eulerto/wal2json) (PostgreSQL 18 and lower)
- [pldebugger](https://github.com/EnterpriseDB/pldebugger) (PostgreSQL 18 and lower)
- [pljs](https://github.com/plv8/pljs) (PostgreSQL 18 and lower)

## How To Build

Postgres.app consists of separate parts:

1) The PostgreSQL binaries, including extensions and a bunch of command line tools.
   You can find the binaries in /Applications/Postgres.app/Contents/Versions

2) The Postgres.app user interface, written in Swift.
   This is the native Mac app that you see when you double click Postgres.app in the Finder.

For compatibility reasons we build the different parts on different versions of macOS.

- the binaries for PostgreSQL 15 - 16 are built on macOS 12 with Command Line Tools for Xcode 14

- the binaries for PostgreSQL 17 - 18 are built on macOS 14 with Command Line Tools for Xcode 15.3

- the binaries for PostgreSQL 19 are built on macOS 26 with Command Line Tools for Xcode 26.6

- the GUI is built on macOS 26 with Xcode 26.6

It is of course possible to use other versions of macOS / Xcode (see details below), but those are the environments we use.

### Building the GUI

If you want to work on the user interface only, you don't have to re-compile the binaries yourself.
By default, the buildscript for Postgres.app just copies the binaries from `/Applications/Postgres.app/Contents/Versions`

So just make sure you have a copy of Postgres.app in your applications folder.
Open the XCode file and start hacking!

Tools required for building the GUI:

- Xcode 11 or later (Swift 5 support is required)

### Building the Binaries

If you want to build your own versions of all the PostgreSQL binaries, you have slightly more work to do.

The directories `src-xx` each contain a makefile that downloads and builds all the binaries.
If you have all the prerequisites installed (see below), you can just type `make`.

The makefile will download and build many gigabytes of sources. The default target (`all`) builds postgresql, postgis, pgvector with
all required dependencies. Before PostgreSQL 19 also pgrouting, pljs, wal2json and pldebugger are built - these are
[downloadable extensions](https://postgresapp.com/extensions/) in later versions.
PostGIS with all its dependencies takes a long time to build, so if you don't need them, type `make postgresql` instead.

The makefile will install all products in `/Applications/Postgres.app/Contents/Versions/xx` (xx is the major version of PostgreSQL).
So for best results, make sure that directory is empty before starting the build.

If you want to change the version number of any of the dependencies, edit the makefile (all version numbers are specified at the top).

You can use the `-j` option (eg. `make -j 8 postgresql`) for parallel builds. Recent processors offer a lot of cores that can be used to speed
up builds but due to build order dependencies, the degree of parallelism that can be used until the end of build is limited.
However, parallel builds make debugging problems a lot harder, so don't use them when something doesn't work.

Always check the exit code of make to see if any errors occurred, eg. `make -j 8 || echo "Build failed with exit code $?"`

### Prerequisites for building the binaries

At the very least, you need the following:

- XCode Command Line Tools (install with `xcode-select --install`)
- Python from [python.org](https://www.python.org/downloads/macos/) in version 3.11.x (PostgreSQL 15), 3.12.x (PostgreSQL 16), 3.13.x (PostgreSQL 17)
  or >=3.9.x (PostgreSQL >=18)

For building PostGIS and its dependencies, you also need

- autoconf
- automake
- pkgconfig
- libtool
- cmake

By default, PostgreSQL is built with documentation. To build the PostgreSQL docs, you need these packages (see
[PostgreSQL Docs](https://www.postgresql.org/docs/current/docguide-toolsets.html) for details):

- docbook-xml-4.5
- docbook-xsl-nons
- fop

The quickest way to install all the dependencies is with MacPorts. Install MacPorts, then type:

    sudo port -N install autoconf automake pkgconfig libtool docbook-xml-4.5 docbook-xsl-nons fop

(The `-N` flag tells Macports to install required dependencies without asking)

It is also possible to install those using homebrew:

    brew install automake cmake docbook-xsl pkgconf

Older versions may require different sets of packages for building.

## Under the Hood

Postgres.app bundles the PostgreSQL binaries inside the application package. When you first start Postgres.app, here's what it does:

- Initialise a database cluster: `initdb -D DATA_DIRECTORY -U postgres --encoding=UTF-8 --locale=en_US.UTF-8`. Starting with PostgreSQL 15 additionally: `--locale-provider=icu --icu-locale=en-US --data-checksums`
- Start the server: `pg_ctl start -D DATA_DIRECTORY --wait --log=DATA_DIRECTORY/postgres-server.log --options="-p PORT"`
- Create a superuser: `createuser -U postgres -p PORT --superuser USERNAME`
- Create a user database: `createdb USERNAME`

On subsequent app launches, Postgres.app only starts the server.

The default `DATA_DIRECTORY` is `/Users/USERNAME/Library/Application Support/Postgres/var-xx`

Note that Postgres.app runs the server as your user, unlike other installations which might create a separate system user named `postgres`.

When you stop a server the following command is performed. The same happens for all running servers if quit Postgres.app using the menubar icon:

- `pg_ctl stop --mode=fast --wait -D DATA_DIRECTORY`

## Command Line Utilities

Postgres.app also includes useful command line utilities (note: this list may be outdated):

- PostgreSQL: `clusterdb` `createdb` `createlang` `createuser` `dropdb` `droplang` `dropuser` `ecpg` `initdb` `oid2name` `pg_archivecleanup` `pg_basebackup` `pg_config` `pg_controldata` `pg_ctl` `pg_dump` `pg_dumpall` `pg_receivexlog` `pg_resetxlog` `pg_restore` `pg_standby` `pg_test_fsync` `pg_test_timing` `pg_upgrade` `pgbench` `postgres` `postmaster` `psql` `reindexdb` `vacuumdb` `vacuumlo`
- PROJ.4: `cs2cs` `geod` `invgeod` `invproj` `nad2bin` `proj`
- GDAL: `gdal_contour` `gdal_grid` `gdal_rasterize` `gdal_translate` `gdaladdo` `gdalbuildvrt` `gdaldem` `gdalenhance` `gdalinfo` `gdallocationinfo` `gdalmanage` `gdalserver` `gdalsrsinfo` `gdaltindex` `gdaltransform` `gdalwarp` `nearblack` `ogr2ogr` `ogrinfo` `ogrtindex` `testepsg`
- PostGIS: `pgsql2shp` `raster2pgsql` `shp2pgsql`

See [the documentation](http://postgresapp.com/documentation) for more info.

## Contact

If you find a bug, please [open an issue](https://github.com/PostgresApp/PostgresApp/issues).

Postgres.app is maintained by [Jakob Egger](https://github.com/jakob) and [Tobias Bussmann](https://github.com/tbussmann).

## License

Postgres.app is released under the PostgreSQL License. See LICENSE for additional information.
