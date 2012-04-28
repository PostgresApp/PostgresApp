# Postgres.app

Postgres.app is the easiest way to get started with PostgreSQL on the Mac. Open the app, and you have a PostgreSQL server ready and awaiting new connections. Close the app, and the server shuts down.

## Download

> [Download the Latest Build (Beta 3)](http://postgres-app.s3.amazonaws.com/Postgres-for-Mac-Beta-3.zip)

## How To Build

1. Open `Postgres.xcodeproj` in Xcode
2. Select the "Postgres Binaries" scheme, and build by clicking "Run", or using the keyboard shortcut, `⌘B`.
3. Once the binaries are finished building, select the "Postgres Mac Application" scheme, and build & run by clicking "Run", or using the keyboard shortcut, `⌘R`.

## Under the Hood

Postgres.app bundles the PostgreSQL binaries as auxiliary executables. An `NSTask` runs  `postgres` as a `launchd` service, and is terminated when the app is quit.

The database data directory is located in the `/var` directory of the Postgres.app Application Support directory. When the app is launched, it checks for "PG_VERSION" in the directory. If it does not exist, `initdb` is run, and later, `createdb` to create a default database for the current user.

## Contact

Mattt Thompson

- http://github.com/mattt
- http://twitter.com/mattt
- mattt@heroku.com

## License

Postgres.app is released under the PostgreSQL License. See LICENSE for additional information.
