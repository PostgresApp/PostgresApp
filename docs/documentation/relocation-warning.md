---
redirect_from:
  - /l/relocation_warning/
title: Why you should place Postgres.app inside your Applications folder 
---


Why you should place Postgres.app inside your Applications folder
=================================================================

Postgres.app is designed to run from /Applications. Beginning with Postgres.app version 2.6, you can start it from other locations, but some features might not work correctly.

- Linking software with libraries provided by Postgres.app will not work.
  This means installing the ruby gem `pg` or the Python library `psycopg2` will not work.
  
- Building custom extensions that are not included with Postgres.app will not work

- on macOS 12 and earlier, automatic start of PostgreSQL servers won't work

This is why Postgres.app shows a warning on launch if it isn't located in /Applications

Launching Postgres.app directly from the disk image
---------------------------------------------------

It is possible to lauch Postgres.app directly from the disk image, with the limitations above, and two extra limitations:

- automatic updates do not work if the app is launched from the disk image

- automatc starting of PostgreSQL servers in the background does not work if the app is launched from the disk image

- all the limitations above apply as well

For more details, see [issue #693](https://github.com/PostgresApp/PostgresApp/issues/693)