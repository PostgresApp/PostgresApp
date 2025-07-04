---
layout: documentation
title: Postgres.app Erweiterungen
---

## Mitgelieferte Erweiterungen

Postgres.app enthält viele beliebte Erweiterungen:

- **Contrib Module**: adminpack, amcheck, autoinc, bloom, btree_gin, btree_gist, citext, cube, dblink, dict_int, dict_xsyn, earthdistance, file_fdw, fuzzystrmatch, hstore, hstore_plpython3u, insert_username, intagg, intarray, isn, jsonb_plpython3u, lo, ltree, ltree_plpython3u, moddatetime, old_snapshot, pageinspect, pg_buffercache, pg_freespacemap, pg_prewarm, pg_stat_statements, pg_surgery, pg_trgm, pg_visibility, pg_walinspect, pgcrypto, pgrowlocks, pgstattuple, plpgsql, plpython3u, postgres_fdw, refint, seg, sslinfo, tablefunc, tcn, tsm_system_rows, tsm_system_time, unaccent, uuid-ossp, xml2
- **PostGIS**: postgis, postgis_raster, postgis_sfcgal, postgis_tiger_geocoder, postgis_topology, address_standardizer, address_standardizer_data_us
- pgrouting
- vector
- pljs
- **PL Debugger**: pldbgapi

Für die meisten Erweiterungen genügt es, den folgenden SQL-Befehl auszuführen:  
`CREATE EXTENSION extension_name;`

Wenn du PL/Python verwenden möchtest, musst du zuerst Python von [https://python.org](https://python.org) installieren.  
Sieh dir dazu diese [Anleitung](/documentation/plpython.html) an.

Eine vollständige Liste aller verfügbaren Erweiterungen erhältst du mit dem SQL-Befehl:  
`SELECT * FROM pg_available_extensions`

## Download von zusätzlichen Erweiterungen

Ab PostgreSQL 18 stellen wir einige zusätzliche Erweiterungen als separaten Download zur Verfügung.

Diese Erweiterungen müssen unabhängig von der Haupt-App installiert werden. So funktioniert die Installation:

1. Lade das Installationspaket (.pkg) herunter  
2. Doppelklicke auf die .pkg-Datei, um die Erweiterung zu installieren  
3. Starte den PostgreSQL-Server neu  
4. Nun kannst du mit `CREATE EXTENSION extension_name;` oder `ALTER EXTENSION extension_name UPDATE;` die Erweiterung in deiner Datenbank installieren oder aktualisieren

Diese Erweiterungen sind mit Postgres.app 2.8.3 oder neuer und PostgreSQL 18beta1 kompatibel:

- http: [http-pg18-1.6.3.pkg](https://github.com/PostgresApp/Extensions/releases/download/http-1.6.3/http-pg18-1.6.3.pkg)
- PL/v8: [plv8-pg18-3.2.3.pkg](https://github.com/PostgresApp/PostgresApp/releases/download/v2.8.3/plv8-pg18-3.2.3.pkg)
- pg_parquet: [pg_parquet-pg18-0.4.0.pkg](https://github.com/PostgresApp/Extensions/releases/download/pg_parquet-0.4.0/pg_parquet-pg18-0.4.0.pkg)

## Erweiterungen selbst kompilieren

Du kannst auch Erweiterungen selbst kompilieren.  
Wenn du PostgreSQL 18 oder neuer verwendest, sollten sie im das Verzeichnis *Application Support* installiert werden.

Zuerst solltest du sicherstellen, dass dein Pfad korrekt eingerichtet ist:

```sh
which pg_config
```

Die Ausgabe dieses Befehls sollte sein:
/Applications/Postgres.app/Contents/Versions/latest/bin/pg_config

Hier ein Beispiel-Skript zum Kompilieren einer Erweiterung (ersetze 18 durch die verwendete PostgreSQL-Version):

```
git clone git@github.com:theory/pg-envvar.git
cd pg-envvar
make
make install prefix="$HOME/Library/Application Support/Postgres/Extensions/18/local"
```

Starte anschließend den PostgreSQL-Server neu. Danach kannst du die Erweiterung wie gewohnt mit `CREATE EXTENSION` installieren.

### Erweiterungen für PostgreSQL 17 und älter kompilieren

PostgreSQL 17 lädt Erweiterungen nur aus bestimmten Verzeichnissen innerhalb des App-Bundles.

Du kannst sie trotzdem kompilieren und installieren, beachte dabei aber zwei Dinge:
	1.	Die Terminal-App benötigt Berechtigungen, um Apps zu verändern. Sonst erhältst du beim Installieren Fehlermeldungen wie „Operation not permitted“.
	2.	Beim Aktualisieren von Postgres.app werden manuell installierte Erweiterungen entfernt. Du musst sie nach einem Update erneut installieren.
