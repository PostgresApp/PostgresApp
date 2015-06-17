---
layout: documentation.de
title: Installation, Upgrade und Deinstallation von Postgres.app
---

## Postgres.app installieren

Ziehe Postgres.app einfach in den Ordner Programme um es zu installieren.

Beim ersten Öffnen wird Postgres.app einen neuen Datenbankcluster initialisieren und eine leere Datenbank mit deinem Benutzernamen erstellen.
Das kann einige Sekunden dauern. Sobald das erledigt ist, kannst du auf “Open psql” klicken um eine Verbindung zur Datenbank aufzubauen.

Wenn du von der Kommandozeile aus arbeiten willst, solltest du den Pfad konfigurieren. Mehr dazu findest du unter [Programme für die Kommandozeile](cli-tools.html).

Natürlich gibt es aber auch [graphische Clients für PostgreSQL](gui-tools.html).

### Wichtige Verzeichnise

- Binaries: `/Applications/Postgres.app/Contents/Versions/9.4/bin`
- Header: `/Applications/Postgres.app/Contents/Versions/9.4/include`
- Bibliotheken: `/Applications/Postgres.app/Contents/Versions/9.4/lib`
- Datenverzeichnis (data directory): `~/Library/Application Support/Postgres/var-9.4`

## Upgrade von einer früheren Version

Seit Version 9.2.2.0 ist die Versionsnummer von Postgres.app an die Versionsnummer von PostgreSQL gebunden: die ersten drei Ziffern entsprechen der inkludierten Version von PostgreSQL, die letzte Ziffer ist eine laufende Nummer für Bugfixes an Postgres.app selbst.

Upgrades zu einer neuen Bugfix-Version von PostgreSQL (zB. `9.3.0.0` → 9.3.1.0 oder `9.3.1.0` → `9.3.1.1`) sind ganz einfach: Postgres.app beenden, neue Version in den Ordner „Programme“ ziehen, fertig.

Bei einem größeren Update (zB. 9.3.x auf 9.4.x) erstellt Postgres.app automatisch ein neues, leeres Datenverzeichnis. Du musst deine Daten selbst migrieren. Dazu gibt es zwei Möglichkeiten:

### Migration mit `pg_dump` (empfohlen)

1. Stelle sicher dass die alte Version von Postgres.app noch läuft, und hol dir eine Liste von Datenbanken mit dem Kommando `psql --list`.
1. Erstelle einen Dump von jeder Datenbank die du migrieren willst mit `pg_dump datenbankname > datenbankname.sql`
1. Wenn du Benutzer oder Tablespaces konfiguriert hast, exportiere sie mit `pg_dumpall --globals-only > globals.sql`
1. Beende die alter Version von Postgres.app, starte die neue Version
1. Falls zutreffend, stelle Benutzer etc. wieder her mit `psql -f globals.sql`
1. Erstelle nun die benötigten Datenbanken: `createdb datenbankname`
1. Importiere nun die Daten in jede deiner Datenbanken mit `psql -d datenbankname -f datenbankname.sql`
1. Sobald du sicher bist das alles funktioniert kannst du das alte Datenverzeichnis löschen


### Migration mit `pg_upgrade`

`pg_upgrade` ist etwas komplizierter, weil es die Binaries der alten und neuen Version gleichzeitig benötigt. Sinn macht es nur wenn du sehr große Datenbanken hast und `pg_dump` zu langsam ist oder zuviel Festplattenspeicher benötigt. Bevor du mit `pg_upgrade` beginnst, solltest du sicher sein dass du den Prozess genau verstehst, und ein Backup hast!

Weil `pg_upgrade` alte und neue Binaries gleichzeitig braucht, musst du eine spezielle Version von Postgres.app erstellen. Hier zum Beispiel der Prozess für das Update von 9.3 auf 9.4:

1. Rechtsklick auf das alte Postgres.app und "Paketinhalt zeigen" auswählen
1. Rechtsklick auf das neue Postgres.app und "Paketinhalt zeigen" auswählen
3. Kopiere den Ornder `Contents/Versions/9.3` von der alten Postgres.app in die neue Postgres.app
4. Bewege nun die modifizierte, neue Version von Postgres.app in den Programme-Ordner.
5. Verwende `pg_upgrade` entsprechend der Anleitung [in der PostgreSQL Dokumentation](http://www.postgresql.org/docs/current/static/pgupgrade.html).
6. Siehe auch [issue 241](https://github.com/PostgresApp/PostgresApp/issues/241) für mehr Infos wie man mit Fehlern umgeht.

## Postgres.app deinstallieren

1. Postgres.app beenden
2. Postgres.app in den Papierkorb ziehen
3. Datenverzeichnis in den Papierkorb ziehen (Standardort: `~/Library/Application Support/Postgres/var-9.4`)

