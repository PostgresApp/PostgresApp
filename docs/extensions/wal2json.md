---
layout: documentation
title: Using wal2json with Postgres.app
---

## Using wal2json with Postgres.app

[wal2json](https://github.com/eulerto/wal2json) is an logical decoding output plugin for changeset extraction.

Changes can be consumed using the streaming protocol (`pg_recvlogical`) or by a special SQL API.

We are offering wal2json as an additional download for Postgres.app.

### Installing wal2json for Postgres.app

1. Download the wal2json installer package from https://postgresapp.com/extensions/
2. Double click the package and go through all steps to install the extension
3. Find the `postgresql.conf` file for your server
   - open Postgres.app
   - click the "Server Settings…" button
   - find the "Config" file path and click "Show"
   - open the config file with your favorite text editor
4. Update configuration parameters:
   - add wal2json to output plugin libraries, eg. `output_plugin_libraries = 'pgoutput, test_decoding, wal2json'`
5. Restart the PostgreSQL server

Done! You can now use the output plugin. The [readme](https://github.com/eulerto/wal2json#examples) provides sample uses as a kickstart.
