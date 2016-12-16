---
layout: documentation
title: Alternative Methoden zur Migration von Daten bei einem Update von Postgres.app
---

## Datenmigration

Bei einem Update zu einer neuen "Major Version" von PostgreSQL (zb. 9.5 auf 9.6) musst du deine Daten manuell migrieren.
Am einfachsten geht das mit pg_dumpall, aber es gibt auch alternative Methoden.
Die können nützlich sein, wenn du eine sehr große Datenbank hast, oder nur einen Teil deiner Daten migrieren willst.

### Migration mit `pg_dumpall`

Diese Methode ist am einfachsten.

1.	Stelle sicher dass die alte Version von Postgres.app noch läuft
1.	Erstelle einen komprimierten SQL-Dump von deinem Server (das kann eine Weile dauern):<br>
	`pg_dumpall --quote-all-identifiers | gzip >postgresapp.sql.gz`
1.	Beende die alte Version von Postgres.app, starte die neue Version
1.	Nun kannst du den SQL-Dump wiederherstellen:<br>
	`gunzip <postgresapp.sql.gz | psql`

### Migration mit `pg_dump`

Mit dieser Methode kannst du auswählen, welche Datenbanken du migrieren willst.

1. Stelle sicher dass die alte Version von Postgres.app noch läuft, und hol dir eine Liste von Datenbanken mit dem Kommando `psql --list`.
1. Erstelle einen Dump von jeder Datenbank die du migrieren willst mit `pg_dump datenbankname > datenbankname.sql`
1. Wenn du Benutzer oder Tablespaces konfiguriert hast, exportiere sie mit `pg_dumpall --globals-only > globals.sql`
1. Beende die alte Version von Postgres.app, starte die neue Version
1. Falls zutreffend, stelle Benutzer etc. wieder her mit `psql -f globals.sql`
1. Erstelle nun die benötigten Datenbanken: `createdb datenbankname`
1. Importiere nun die Daten in jede deiner Datenbanken mit `psql -d datenbankname -f datenbankname.sql`
1. Sobald du sicher bist das alles funktioniert kannst du das alte Datenverzeichnis löschen


### Migration mit `pg_upgrade`

`pg_upgrade` ist etwas komplizierter, weil es die Binaries der alten und neuen Version gleichzeitig benötigt. Sinn macht es nur wenn du sehr große Datenbanken hast und `pg_dump` zu langsam ist oder zuviel Festplattenspeicher benötigt. Bevor du mit `pg_upgrade` beginnst, solltest du sicher sein dass du den Prozess genau verstehst, und ein Backup hast!

Weil `pg_upgrade` alte und neue Binaries gleichzeitig braucht, musst du eine spezielle Version von Postgres.app erstellen. Hier zum Beispiel der Prozess für das Update von 9.4 auf 9.5:

1. Beende Postgres.app
2. Rechtsklick auf das alte Postgres.app und "Paketinhalt zeigen" auswählen
3. Rechtsklick auf das neue Postgres.app und "Paketinhalt zeigen" auswählen
4. Kopiere den Ordner `Contents/Versions/9.4` von der alten Postgres.app in die neue Postgres.app
5. Bewege nun die modifizierte, neue Version von Postgres.app in den Programme-Ordner
6. Lösche nun den Ordner `~/Library/Application Support/Postgres/var-9.5` (falls er existiert) und erstelle ein leeres Verzeichnis mit dem Namen `var-9.5`
7. Initialisiere einen neuen Datenbankcluster mit dem Befehl `/Applications/Postgres.app/Contents/Versions/9.5/bin/initdb -D ~/Library/Application\ Support/Postgres/var-9.5 --encoding=UTF-8 --locale=en_US.UTF-8`
8. Führe das Migration durch mit dem Befehl `/Applications/Postgres.app/Contents/Versions/9.5/bin/pg_upgrade -b /Applications/Postgres.app/Contents/Versions/9.4/bin -B /Applications/Postgres.app/Contents/Versions/9.5/bin -d ~/Library/Application\ Support/Postgres/var-9.4 -D ~/Library/Application\ Support/Postgres/var-9.5 -v` (siehe auch die [Dokumentation von pg_upgrade](http://www.postgresql.org/docs/current/static/pgupgrade.html))
9. `pg_upgrade` erstellt zwei Skripte, `analyze_new_cluster.sh` und `delete_old_cluster.sh`. Du kannst sie verwenden um das neue Datenverzeichnis zu optimieren und das alte zu löschen.
