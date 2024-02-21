---
layout: documentation
title: Infos zur Konfiguration von Postgres.app
---

## Mitgelieferte Software

Postgres.app enthält eine vollständige PostgreSQL-Installation mit allen contrib-Erweiterungen (zb. hstore, uuid, etc.).
Zusätzlich sind auch PostGIS und ein paar andere Erweiterungen mit dabei.

- [PostgreSQL](http://www.postgresql.org/)
- [PostGIS](http://postgis.refractions.net/)

## Verbindungsparameter
- **Host:** localhost
- **Port:** 5432 (default)
- **Benutzer:** *dein lokaler Benutzername*
- **Passwort:** *leer*
- **Datenbank:** *gleich wie Benutzername*

## Verbindungen von anderen Computern erlauben

Die Standardeinstellung von PostgreSQL erlaubt nur Verbindungen von localhost, und benötigt kein Passwort.

Um Verbindungen von anderen Computern zu ermöglichen, musst du den Parameter `listen_address`
in der Datei `postgresql.conf` ändern. Diese Datei findest du im Datenverzeichnis.
Mehr Information findest du in der PostgreSQL Dokumentation unter
[Connections and Authentication](https://www.postgresql.org/docs/current/runtime-config-connection.html).

Ausserdem musst du die Datei [`pg_hba.conf`](https://www.postgresql.org/docs/current/auth-pg-hba-conf.html) bearbeiten.
Hier legst du fest, welche Benutzer von welchen IP-Adressen auf die Datenbank zugreifen können.

Nach Änderungen an diesen Konfigurationsdateien musst du Postgres.app neu starten.

## Wichtige Verzeichnisse

- Datenverzeichnis: `~/Library/Application\ Support/Postgres/var-9.6` (Kann in den Einstellungen geändert werden)
- Ausführbare Dateien: `/Applications/Postgres.app/Contents/Versions/9.6/bin`
- Header: `/Applications/Postgres.app/Contents/Versions/9.6/include`
- Bibliotheken: `/Applications/Postgres.app/Contents/Versions/9.6/lib`
- Man-Seiten: `/Applications/Postgres.app/Contents/Versions/9.6/share`
- Konfiguration: `~/Library/Application\ Support/Postgres/var-9.6/postgresql.conf`

