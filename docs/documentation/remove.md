---
layout: documentation
title: Removing Existing PostgreSQL Installations
---

## Removing existing PostgreSQL Installations

Postgres.app can't start when another server is already running on the same port (default: 5432).
We recommend to uninstall other PostgreSQL installations before using Postgres.app.

Before you uninstall, make sure to back up any data you might have stored in the database using pg_dump.
See [Migrating data](migrating-data.html) for details.

After uninstalling, open “Activity Monitor” and make sure there are no processes named “postgres” or “postmaster”;
otherwise Postgres.app might not be able to start.

### Homebrew

``` bash
$ brew remove postgresql
````

### MacPorts

First use the `installed` command to determine which version of the PostgreSQL server you have installed:

``` bash
$ sudo port installed
```

Then uninstall the server. If you are using version 9.4, the command would be:

``` bash
$ sudo port uninstall postgresql94-server
```

After uninstalling, the server might still be running. Use Activity Monitor to kill the server processes, or reboot your Mac.

### EnterpriseDB

EnterpriseDB provides an uninstaller that can automatically uninstall PostgreSQL.
You can find it in the installation directory.

The default EnterpriseDB installation directory is `/Library/PostgreSQL`. To open this directory, use the “Go To Folder” command in Finder (⌘⇧G) and type `/Library/PostgreSQL`.

Then double click on the “uninstall-postgresql” application.

### Kyng Chaos

To uninstall the Kyng Chaos distribution, follow [these instructions](http://comments.gmane.org/gmane.comp.gis.postgis/32157).
