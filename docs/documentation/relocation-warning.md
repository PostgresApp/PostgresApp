---
redirect_from:
  - /l/relocation_warning/
title: Why you should place Postgres.app inside your Applications folder 
---


Why you should place Postgres.app inside your Applications folder
=================================================================

Postgres.app is designed to run from /Applications. Beginning with Postgres.app version 2.6, you can start it from other locations, but some features might not work correctly.

- Automatic start of PostgreSQL servers on login might not work correctly

- Linking software with libraries provided by Postgres.app will not work correctly. This means installing the ruby gem `pg` or the Python library `psycopg2` will not work. It should theoretically be possible to build them by changing the install name of the libraries, but this is something that we haven't really figured out yet.

- When adding servers, Postgres.app stores the binary location of the currently running app in the settings. If you move Postgres.app, it won't find the binaries. You will need to remove and re-add the server to fix this (removing a server from the sidebar does not delete the data).

This is why Postgres.app shows a warning on launch if it isn't located in /Applications

For more details, see [issue #693](https://github.com/PostgresApp/PostgresApp/issues/693)