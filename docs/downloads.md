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

If you are using a very old version of macOS, please see our [legacy downloads](downloads_legacy.html).
