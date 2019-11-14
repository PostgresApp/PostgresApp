---
layout: documentation
title: Postgres.app Legacy Downloads
---

Legacy Downloads for older Macs
-----------------------

We no longer update our legacy releases.


We provide these downloads for people who are still on older versions of macOS, but we no longer update them.


If you are running macOS 10.10 or later, you can use Postgres.app v2.1.x with the modern UI.

If you have an even older Mac, you can use the Legacy version of Postgres.app (supports only a single version of PostgreSQL).

{% for release in site.legacyReleases %}
	{% include release.html release=release %}
{% endfor %}

You can find even more releases on our <a href="https://github.com/PostgresApp/PostgresApp/releases/">Releases Page</a> on Github.
