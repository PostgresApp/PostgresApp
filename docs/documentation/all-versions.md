---
layout: documentation
title: Supported versions of Postgres.app
---

Postgres.app {{site.postgresappVersion}}
----------------------------------------

This is the current version of Postgres.app.
It requires macOS&nbsp;{{site.postgresappMinSystemVersion}} or later.

It includes the following binaries:
{% for postgresqlVersion in site.postgresqlVersions %}
- PostgreSQL {{ postgresqlVersion.postgres }} (with PostGIS {{ postgresqlVersion.postgis }})
{% endfor %}

[Release Notes for Postgres.app {{site.postgresappVersion}}]({{site.releaseNotesLocation}})

[Download Postgres.app {{site.postgresappVersion}}]({{site.downloadLocation}})

PostgreSQL 11 Beta
------------------

We also provide beta builds of Postgres.app with PostgreSQL 11. Please check out the 
<a href="https://github.com/PostgresApp/PostgresApp/releases/">Releases Section</a> on Github for the most recent build.


Legacy Versions
---------------

We also continue to support a number of legacy versions of Postgres.app.
These legacy versions require only macOS&nbsp;{{site.legacyMinSystemVersion}} or later.
They each contain a single version of PostgreSQL.
They don't have the modern user interface of the current version.

{% for legacyVersion in site.legacyVersions %}
- PostgreSQL {{legacyVersion.postgresqlVersion}}, PostGIS {{legacyVersion.postgisVersion}}  
  [Release Notes]({{legacyVersion.releaseNotes}}), [Download]({{legacyVersion.downloadLocation}})
{% endfor %}


Mix & Match
-----------

If you'd like to use the modern UI, but need to work with an older version of PostgreSQL,
you can combine the binaries from a legacy version with the UI of the new version.

The binaries are contained inside the application package.
Right click on the app, and select "Show Package Contents".
You can now find the binaries in the subdirectory `Contents/Versions`.

Now you can just copy an older binary folder (eg. 9.3) from a legacy version to the current version.

Done! You can now run PostgreSQL servers with multiple versions at the same time!

If Finder refuses to start Postgres.app because the code signature can no longer be verified, right click on the app and select "Open".

There is one caveat: the automatic update function will delete your extra binaries, so you'll need to add them again after updating.