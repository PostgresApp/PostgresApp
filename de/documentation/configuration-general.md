---
layout: documentation.de
title: Infos zur Konfiguration von Postgres.app
---

## Mitgelieferte Software

Postgres.app enthält eine vollständige PostgreSQL-Installation mit allen contrib-Erweiterungen (zb. hstore, uuid, etc.).
Zusätzlich sind auch PostGIS und plv8 mit dabei.

- [PostgreSQL](http://www.postgresql.org/)
- [PostGIS](http://postgis.refractions.net/)
- [plv8](http://code.google.com/p/plv8js/wiki/PLV8)

## Verbindungsparameter
- **Host:** localhost
- **Port:** 5432 (default)
- **Benutzer:** *dein lokaler Benutzername*
- **Passwort:** *leer*
- **Datenbank:** *gleich wie Benutzername*


## Wichtige Verzeichnisse

- Datenverzeichnis: `~/Library/Application\ Support/Postgres/var-9.4` (Kann in den Einstellungen geändert werden)
- Ausführbare Dateien: `/Applications/Postgres.app/Contents/Versions/9.4/bin`
- Header: `/Applications/Postgres.app/Contents/Versions/9.4/include`
- Bibliotheken: `/Applications/Postgres.app/Contents/Versions/9.4/lib`
- Man-Seiten: `/Applications/Postgres.app/Contents/Versions/9.4/share`

