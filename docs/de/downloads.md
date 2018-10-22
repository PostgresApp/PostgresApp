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

Wir bieten aktuelle Versionen von PostgreSQL auch für ältere Macs!

Auf macOS 10.10 oder neuer kannst du Postgres.app v2.1.x mit der modernen Benutzeroberfläche verwenden.

Noch älteren Macs (10.7+) unterstützen die "Legacy"-Version von Postgres.app mit der alten Benutzeroberfläche.

{% for release in site.legacyReleases %}
	{% include release.html release=release %}
{% endfor %}

Noch mehr Versionen findest du auf der <a href="https://github.com/PostgresApp/PostgresApp/releases/">Releases-Seite</a> auf Github.

Vorabversionen
--------------

Wir bauen auch Alpha- und Beta-Versionen von PostgreSQL.
Solltest du oben nichts finden, sind sie vielleicht nur auf der <a href="https://github.com/PostgresApp/PostgresApp/releases/">Releases-Seite</a> auf Github.


Baukastensystem
---------------

Die aktuelle Version von Postgres.app unterstützt die Verwendung von mehreren Versionen von PostgreSQL.
Oben findest du Downloads mit verschiedenen PostgreSQL-Serverversionen.
Du kannst dir aber auch deine eigene Version zusammenstellen.

Um die Binaries für die verschiedenen Server-Versionen in Postgres.app anzuzeigen, 
klicke mit der rechten Maustaste auf Postgres.app und wähle "Paketinhalt zeigen".
Du findest die Binaries dann im Unterordner `Contents/Versions`.

Wenn du also zb. PostgreSQL 9.4 und 11 verwenden willst, kopiere den `9.4` Ordner aus einer Legacy-Version in die neue Version.

Wenn du nun Postgres.app neu startest, kannst du einen neuen Server mit PostgreSQL 9.4 erstellen.

Durch die zusätzlichen Dateien im Paket kann die Codesignatur eventuell nicht mehr überprüft werden.
Finder überprüft die Code-Signatur nur beim ersten Öffnen. Stelle daher sicher, dass du Postgres.app zumindest einmal geöffnet hast, bevor du Änderungen vornimmst.

Noch eine kurze Warnung: Die automatische Update-Funktion löscht zusätzliche PostgreSQL-Versionen.
Du musst nach einem Update wieder die alten Binaries kopieren.
