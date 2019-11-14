---
layout: documentation
title: Postgres.app Downloads
redirect_from: "/de/documentation/all-versions.html"
---

Aktuelle Version
--------------
Diese Version enthält alles was du für die Arbeit mit PostgreSQL and PostGIS benötigst.

{% include release.html release=site.release %}

Zusätzliche Versionen
-------------------
Wenn du andere PostgreSQL-Versionen benötigst bist du hier richtig. Du kannst mit Postgres.app sogar unterschiedliche PostgreSQL-Versionen gleichzeitig benützen!

{% for release in site.extraReleases %}
	{% include release.html release=release %}
{% endfor %}

Für ältere Macs
---------------

Wenn du macOS 10.12 noch nicht installiert hast, findest du ältere Versionen [hier](downloads_legacy.html).
