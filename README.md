# Postgres.app

Postgres.app is the easiest way to get started with PostgreSQL on the Mac. Open the app, and you have a PostgreSQL server ready and awaiting new connections. Close the app, and the server shuts down.

Postgres.app will be distributed through the Mac App Store, with a separate build containing the latest PostgreSQL beta available for direct download from the website.

## Download

> You can download the latest build [from the Postgres.app website](http://postgresapp.com/)

## Documentation

Documentation is available at [http://postgresapp.com/documentation](http://postgresapp.com/documentation), as well as from the "Open Documentation" menu item in Postgres.app.

## What's Included?

- [PostgreSQL 9.2.4](http://www.postgresql.org/docs/9.1/static/release-9-1-3.html)
- [PostGIS 2.0.1](http://postgis.refractions.net/)
- [plv8](http://code.google.com/p/plv8js/wiki/PLV8)

## How To Build

The XCode project is set up so it automatically downloads and builds the PostgreSQL source code (and other required software packages)

To build Postgres.app with PostgreSQL only:
1. Open `Postgres.xcodeproj` in Xcode
2. Select the `Postgres` scheme, and click "Run"

To build Postgres.app with extensions (PostGIS, v8):
1. Open `Postgres.xcodeproj` in Xcode
2. Select `postgres-binaries` scheme, and build using the keyboard shortcut ⌘B
3. Select `postgres-extensions`, build
4. Select `Postgres`, click run

## Under the Hood

Postgres.app bundles the PostgreSQL binaries as auxiliary executables. An [XPC service](http://developer.apple.com/library/mac/#documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingXPCServices.html) manages `postgres` processes, which are terminated when the app is quit.

The database data directory is located in the `/var` directory of the Postgres.app Container's Application Support directory. When the app is launched, it checks for "PG_VERSION" in the directory. If it does not exist, `initdb` is run, and later, `createdb` to create a default database for the current user.

## Contact

Mattt Thompson

- http://github.com/mattt
- http://twitter.com/mattt
- mattt@heroku.com

## License

Postgres.app is released under the PostgreSQL License. See LICENSE for additional information.
