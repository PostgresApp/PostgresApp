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

- Binaries: `/Applications/Postgres.app/Contents/Versions/9.6/bin`
- Header: `/Applications/Postgres.app/Contents/Versions/9.6/include`
- Bibliotheken: `/Applications/Postgres.app/Contents/Versions/9.6/lib`
- Datenverzeichnis (data directory): `~/Library/Application Support/Postgres/var-9.6`

## Upgrade von einer früheren Version

Seit Version 9.2.2.0 ist die Versionsnummer von Postgres.app an die Versionsnummer von PostgreSQL gebunden: die ersten drei Ziffern entsprechen der inkludierten Version von PostgreSQL, die letzte Ziffer ist eine laufende Nummer für Bugfixes an Postgres.app selbst.

Upgrades zu einer neuen Bugfix-Version von PostgreSQL (zB. `9.3.0.0` → 9.3.1.0 oder `9.3.1.0` → `9.3.1.1`) sind ganz einfach: Postgres.app beenden, neue Version in den Ordner „Programme“ ziehen, fertig.

Bei einem größeren Update (zB. 9.5.x auf 9.6.x) erstellt Postgres.app automatisch ein neues, leeres Datenverzeichnis. Du musst deine Daten selbst migrieren.

### Migration mit `pg_dumpall`

1.	Stelle sicher dass die alte Version von Postgres.app noch läuft
1.	Erstelle einen komprimierten SQL-Dump von deinem Server (das kann eine Weile dauern):<br>
	`pg_dumpall --quote-all-identifiers | gzip >postgresapp.sql.gz`
1.	Beende die alte Version von Postgres.app, starte die neue Version
1.	Nun kannst du den SQL-Dump wiederherstellen:<br>
	`gunzip <postgresapp.sql.gz | psql`

Diese Methode sollte in den meisten Fällen gut funktionieren.
Falls du aber eine sehr große Menge an Daten hast, oder nur Teile deiner Daten migrieren willst,
gibt es [alternative Methoden](migrating-data.html).


## Postgres.app deinstallieren

1. Postgres.app beenden
2. Postgres.app in den Papierkorb ziehen
3. Datenverzeichnis in den Papierkorb ziehen (Standardort: `~/Library/Application Support/Postgres/var-9.5`)

