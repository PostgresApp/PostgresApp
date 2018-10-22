---
layout: documentation
title: Postgres.app Downloads
redirect_from: "/documentation/all-versions.html"
---

Latest Release
--------------
If you're new to Postgres, this is the file you should download. It includes everything you need to get started with PostgreSQL and PostGIS.

{% include release.html release=site.release %}

Additional Releases
-------------------
We provide additional releases for people who want to run other versions of PostgreSQL.
With these releases you can even run multiple versions of PostgreSQL simultaneously.

{% for release in site.extraReleases %}
	{% include release.html release=release %}
{% endfor %}

Releases for older Macs
-----------------------

We continue to make up to date builds for older Macs!

If you are running macOS 10.10 or later, you can use Postgres.app v2.1.x with the modern UI.

If you have an even older Mac, you can use the Legacy version of Postgres.app (supports only a single version of PostgreSQL).

{% for release in site.legacyReleases %}
	{% include release.html release=release %}
{% endfor %}

You can find even more releases on our <a href="https://github.com/PostgresApp/PostgresApp/releases/">Releases Page</a> on Github.

Prerelease Versions
-------------------

We also build Alpha and Beta releases of PostgreSQL. If they are not listed above,
you can find them on our <a href="https://github.com/PostgresApp/PostgresApp/releases/">Releases Page</a> on Github.

Mix & Match
-----------

If you'd like to use the modern UI, but need to work with an older version of PostgreSQL,
you can combine the binaries from a legacy version with the UI of the new version.

The binaries are contained inside the application package.
Right click on the app, and select "Show Package Contents".
You can now find the binaries in the subdirectory `Contents/Versions`.

Now you can just copy an older binary folder (eg. 9.3) from a legacy version to the current version.

(Make sure that you have started Postgres.app at least once before adding binaries. 
Finder checks the code signature when you open an app for the first time, and the code signature becomes invalid when you add files to the package.)

Done! You can now run PostgreSQL servers with multiple versions at the same time!

There is one caveat: the automatic update function will delete your extra binaries, so you'll need to add them again after updating.