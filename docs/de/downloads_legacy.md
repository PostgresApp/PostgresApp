---
layout: documentation
title: Postgres.app Downloads für ältere Macs
---


Downloads für ältere Macs
---------------

Hier findest du downloads für ältere Macs.

Achtung: Diese werden jetzt nicht mehr gewartet!

Auf macOS 10.10 oder neuer kannst du Postgres.app v2.1.x mit der modernen Benutzeroberfläche verwenden.

Noch älteren Macs (10.7+) unterstützen die "Legacy"-Version von Postgres.app mit der alten Benutzeroberfläche.

{% for release in site.legacyReleases %}
	{% include release.html release=release %}
{% endfor %}

Noch mehr Versionen findest du auf der <a href="https://github.com/PostgresApp/PostgresApp/releases/">Releases-Seite</a> auf Github.
