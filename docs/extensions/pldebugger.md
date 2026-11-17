---
layout: documentation
title: Using pldebugger with Postgres.app
---

## Using pldebugger with Postgres.app

The [pldebugger extension](https://github.com/EnterpriseDB/pldebugger) is a Procedural Language Debugger Plugin for PostgreSQL.

It allows connecting with [pgAdmin](https://www.pgadmin.org/) or other compatible clients to interactively debug PL/pgSQL functions.

We are offering pldebugger as an additional download for Postgres.app.

### Installing pldebugger for Postgres.app

1. Download the pldebugger installer package from https://postgresapp.com/extensions/
2. Double click the package and go through all steps to install the extension
3. Find the `postgresql.conf` file for your server
   - open Postgres.app
   - click the "Server Settings…" button
   - find the "Config" file path and click "Show"
   - open the config file with your favorite text editor
4. Update configuration parameters:
   - add pldebugger to shared preload libraries, eg. `shared_preload_libraries = 'pldebugger'`
5. Restart the PostgreSQL server
6. Connect to the database you want to use pldebugger
7. Activate the extension: `CREATE EXTENSION pldbgapi;`

Done! You can now connect your client to use the debugger for PL/pgSQL.

You can find the full documentation for pldebugger on [GitHub](https://github.com/EnterpriseDB/pldebugger) and its usage in the [pgAdmin documentation](https://www.pgadmin.org/docs/pgadmin4/latest/debugger.html).
