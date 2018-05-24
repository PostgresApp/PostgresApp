---
layout: documentation
title: Unterstützte Versionen von Postgres.app
---

Postgres.app {{site.postgresappVersion}}
----------------------------------------

Dies ist die aktuelle Version von Postgres.app.
Sie benötigt macOS&nbsp;{{site.postgresappMinSystemVersion}} oder neuer.

Folgende Server-Versionen sind im Paket inkludiert:
{% for postgresqlVersion in site.postgresqlVersions %}
- PostgreSQL {{ postgresqlVersion.postgres }} (mit PostGIS {{ postgresqlVersion.postgis }})
{% endfor %}

[Versionshinweise für Postgres.app {{site.postgresappVersion}}]({{site.releaseNotesLocation}})

[Postgres.app {{site.postgresappVersion}} herunterladen]({{site.downloadLocation}})

PostgreSQL 11 Beta
------------------

Wir bieten auch Beta-Versionen mit PostgreSQL 11 zum Download an.
Bitte schau auf die 
<a href="https://github.com/PostgresApp/PostgresApp/releases/">Releases Seite</a> auf Github!


Weitere Versionen
-----------------

Wir unterstützen auch einige ältere Versionen von PostgreSQL.
Diese Versionen laufen auf macOS&nbsp;10.7 oder neuer.
Sie haben noch die alte Benutzeroberfläche, und enthalten jeweils nur eine einzelne Version von PostgreSQL.

{% for legacyVersion in site.legacyVersions %}
- PostgreSQL {{legacyVersion.postgresqlVersion}}, PostGIS {{legacyVersion.postgisVersion}}  
  [Versionshinweise]({{legacyVersion.releaseNotes}}), [Download]({{legacyVersion.downloadLocation}})
{% endfor %}


Baukastensystem
---------------

Die aktuelle Version von Postgres.app unterstützt verschiedene Versionen von PostgreSQL.
Standardmäßig sind 9.5 und 9.6 inkludiert, du kannst aber auch weitere PostgreSQL-Versionen hinzugügen.

Um die Binaries für die verschiedenen Server-Versionen in Postgres.app anzuzeigen, 
klicke mit der rechten Maustaste auf Postgres.app und wähle "Paketinhalt zeigen".
Du findest die Binaries dann im Unterordner `Contents/Versions`.

Wenn du also zb. PostgreSQL 9.4 mit dem neuen UI verwenden willst, kopiere den `9.4` Ordner aus einer alten Version in die neue Version.

Wenn du nun Postgres.app neu startest, kannst du einen neuen Server mit PostgreSQL 9.4 erstellen.

Durch die zusätzlichen Dateien im Paket kann die Codesignatur eventuell nicht mehr überprüft werden.
Falls beim Öffnen der App eine Fehlermeldung auftritt, musst du sie über das Kontext-Menü öffnen.

Noch eine kurze Warnung: Die automatische Update-Funktion löscht zusätzliche PostgreSQL-Versionen.
Du musst nach einem Update wieder die alten Binaries kopieren.
