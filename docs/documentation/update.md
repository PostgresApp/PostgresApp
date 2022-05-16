---
layout: documentation
title: Updating Postgres.app
---

Updating Postgres.app
======================

Versioning
----------
Each version of Postgres.app is available with different major versions of PostgreSQL 
bundled. If you use "Check For Updates…", it will show you new releases either bundled
with the same single major version of PostgreSQL or all supported versions depending on
the release you are currently running.

PostgreSQL itself has major and minor updates (see [versioning policy](https://www.postgresql.org/support/versioning/)). 
Major versions (first part of version number since '10', first two parts till '9.6') are 
released about once a year, contain new features and require a manual process to convert a
data directory to a new major version, see [migrating data](migrating-data.html).
You can run multiple major versions in parallel if you use a multi version bundle of
Postgres.app from the [downloads page](/downloads.html) and different Port numbers.

PostgreSQL minor versions are indicated by the last part of the version number (e.g. 
'14.3' or '9.6.24'). Minor updates are released for all supported major versions about 
once per quarter. These updates only require a restart of the application and are highly 
recommended as they contain bugfixes and security updates both to PostgreSQL and it's
bundled dependencies.

Minor Updates in Postgres.app 2
-------------------------------
Postgres.app 2.0 or later has an automatic update function.
Just open the app, and select "Check For Updates…" from the "Postgres" menu.

While the self-update of Postgres.app and the bundled PostgreSQL binaries generally is an
easy and painless process, we recommend to perform some additional steps:
* Read the release notes of Postgres.app (will be displayed in the check for update 
  window) and check for version specific notes and especially deprecated and removed
  versions of PostgreSQL in the bundle.
* Read the minor release [release notes](https://www.postgresql.org/docs/release/) of the 
  PostgreSQL major version(s) you are using and look for special notes at the top.
  Also do this for all the minor versions that you may have skipped.
* Perform the actions recommended in the release notes. Usually this needs to be done for
  each database separately. 
* If you have installed some of the bundled extensions in your databases, their SQL 
  definitions may need an update as well. You can show an overview of these with the 
  following query:
```sql
SELECT * FROM pg_available_extensions WHERE installed_version IS NOT NULL AND default_version <> installed_version;
```
  If there are results, run `ALTER EXTENSION xyz UPDATE;` for each listed extension xyz. 
  In the likely case, PostGIS extensions are listed, it's better to run 
  `SELECT postgis_extensions_upgrade();` instead to respect all their inner dependencies.
  This again, needs to be done to each database separately.

From Legacy Postgres.app 9.5.x.x, 9.6.x.x or 10.x.x
---------------------------------------------------
You can upgrade to Postgres.app 2 just by replacing the app in your `/Applications` folder.

1. Quit the old version of Postgres.app
2. Download the new version of Postgres.app and double-click the downloaded `.dmg`
3. Replace the old version in `/Applications` with the new version
4. Double-click the new version.
   Postgres.app 2 will automatically detect the existing data directories if they are in the standard location.
   If you are using a different location, add them manually by opening the sidebar and clicking the plus button.



From earlier Legacy versions of Postgres.app
--------------------------------------------

If you want to upgrade from earlier versions of Postgres.app, you will need to [migrate your data](migrating-data.html).

Alternatively, you can make a custom version of Postgres.app 2 that supports the older server versions. See [this page](all-versions.html) for details.
