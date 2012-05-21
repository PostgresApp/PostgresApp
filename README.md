# Postgres.app

Postgres.app is the easiest way to get started with PostgreSQL on the Mac. Open the app, and you have a PostgreSQL server ready and awaiting new connections. Close the app, and the server shuts down.

We plan to distribute Postgres.app through the Mac App Store, with a separate build containing the latest PostgreSQL beta available for direct download from the website.

## Download

> [Download the Latest Build (Beta 4)](http://postgres-app.s3.amazonaws.com/Postgres-for-Mac-Beta-4.zip)

## What's Included?

- [PostgreSQL 9.1.3](http://www.postgresql.org/docs/9.1/static/release-9-1-3.html)
- [PostGIS 2.0](http://postgis.refractions.net/)
- [plv8](http://code.google.com/p/plv8js/wiki/PLV8)

## How To Build

1. Open `Postgres.xcodeproj` in Xcode
2. Select the "Postgres Binaries" scheme, and build by clicking "Run", or using the keyboard shortcut, `⌘B`.
3. Once the binaries are finished building, select the "Postgres Mac Application" scheme, and build & run by clicking "Run", or using the keyboard shortcut, `⌘R`.

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
