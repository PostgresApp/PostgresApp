---
layout: documentation
title: Programme für die Kommandozeile
---

## CLI Tools

### Konfiguriere deine `$PATH` Variable

Postgres.app beinhaltet auch einige Tools für die Kommandozeile. Damit du sie verwenden kannst, musst du die `$PATH` Variable konfigurieren.

Am einfachsten geht das mit:

```bash
sudo mkdir -p /etc/paths.d &&
echo /Applications/Postgres.app/Contents/Versions/latest/bin | sudo tee /etc/paths.d/postgresapp
```

Dieser Befehl erstellt eine Datei, die den Pfad zu den Binaries enthält.
Alternativ kannst du natürlich auch einfach die Konfiguration in deinem `.profile` vornehmen.

Du kannst überprüfen ob der Pfad korrekt konfiguriert ist in dem du den Befehl `which psql` ausführst.

### Mitgelieferte Tools

Die folgenden Tools sind bei Postgres.app dabei:

- PostgreSQL: `clusterdb` `createdb` `createlang` `createuser` `dropdb` `droplang` `dropuser` `ecpg` `initdb` `oid2name` `pg_archivecleanup` `pg_basebackup` `pg_config` `pg_controldata` `pg_ctl` `pg_dump` `pg_dumpall` `pg_receivexlog` `pg_resetxlog` `pg_restore` `pg_standby` `pg_test_fsync` `pg_test_timing` `pg_upgrade` `pgbench` `postgres` `postmaster` `psql` `reindexdb` `vacuumdb` `vacuumlo`
- PROJ.4: `cs2cs` `geod` `invgeod` `invproj` `nad2bin` `proj`
- GDAL: `gdal_contour` `gdal_grid` `gdal_rasterize` `gdal_translate` `gdaladdo` `gdalbuildvrt` `gdaldem` `gdalenhance` `gdalinfo` `gdallocationinfo` `gdalmanage` `gdalserver` `gdalsrsinfo` `gdaltindex` `gdaltransform` `gdalwarp` `nearblack` `ogr2ogr` `ogrinfo` `ogrtindex` `testepsg`
- PostGIS: `pgsql2shp` `raster2pgsql` `shp2pgsql`


### Man-Seiten

Postgres.app beinhaltet natürlich auch Man-Seiten. Solange der Pfad wie oben beschrieben richtig konfiguriert ist, kann man zB. mit `man psql` jederzeit die offizielle Bedienungsanleitung lesen.