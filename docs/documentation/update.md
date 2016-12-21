---
layout: documentation
title: Updating Postgres.app
---

Updating Postgres.app
======================


Postgres.app 2
-------------------------
Postgres.app 2.0 or later has an automatic update function.
Just open the app, and select "Check For Updates…" from the "Postgres" menu.

If you want to convert a data directory to a new major version (eg. 9.5 to 9.6), see [migrating data](migrating-data.html).


From Postgres.app 9.5.x.x or 9.6.x.x
------------------------------------
You can upgrade to Postgres.app 2 just by replacing the the app in your applications folder.

1. Quit the old version of Postgres.app
2. Download the new version of Postgres.app
3. Replace the old version in /Applications with the new version
4. Double click.
   Postgres.app 2 will automatically detect the existing data directories if they are in the standard location.
   If you are using a different location, add them manually by opening the sidebar and clicking the plus button.



From earlier versions of Postgres.app
-------------------------------------

If you want to upgrade from earlier versions of Postgres.app, you will need to [migrate your data](migrating-data.html).

Alternatively, you can make a custom version of Postgres.app 2 that supports the older server versions. See [this page](all-versions.html) for details.
