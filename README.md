# PostgreSQL.app
## "Less Drama, More Awesome"

PostgreSQL.app is a Postgres bottled in a convenient, Mac App Store-compatible package.

One click install, one click uninstall: it should be that easy.

## How To Build

1. Download the [latest Postgres source code](https://github.com/postgres/postgres) to the `postgres` submodule:

``` terminal
$ git submodule init
$ git submodule update
```

2. Open `PostgreSQL.xcodeproj` in Xcode
3. Select the "Postgres Binaries" scheme, and build by clicking "Run", or using the keyboard shortcut, `⌘B`.
4. Once the binaries are finished building, select the "PostgreSQL Mac Application" scheme, and build & run by clicking "Run", or using the keyboard shortcut, `⌘R`.

## Under the Hood

PostgreSQL.app bundles the Postgres binaries as auxiliary executables. An `NSTask` runs  `postgres` as a `launchd` service, and is terminated when the app is quit.

The database data directory is located in the `/var` directory of the PostgreSQL.app Application Support directory. When the app is launched, it checks for "PG_VERSION" in the directory. If it does not exist, `initdb` is run, and later, `createdb` to create a default database for the current user.

## Next Steps

- Create a real UI
- Add PostGIS to the build process (as well as any other essential extensions)
- Add instructions for how to configure with Ruby / Python, etc.
  - ...or better yet, make them work without any additional configuration
- Test, test, test, test, test

## Contact

Mattt Thompson

- http://github.com/mattt
- http://twitter.com/mattt
- mattt@heroku.com

## License

PostgreSQL.app is released under the PostgreSQL License. See LICENSE for additional information.
