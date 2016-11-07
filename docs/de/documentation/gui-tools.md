---
layout: documentation.de
title: GUI Tools für PostgreSQL am Mac
---

Mittlerweile gibt es eine beachtliche Auswahl an grafischen Clients für Postgres am Mac.
Auf dieser Seite findest du eine Übersicht welche Apps es gibt und wie man mit Postgres.app verbindet.


## Postico

<a href="https://eggerapps.at/postico/" style="float:right;">
<img src="https://eggerapps.at/postico/img/icon_256x256.png" alt="Postico App Icon" style="width: 128px;height:128px;">
</a>

[Postico](https://eggerapps.at/postico/) ist ein sehr moderner und benutzerfreundlicher Client für OS X.
Entwickelt wird Postico von Jakob Egger, dem aktuellen Maintainer von Postgres.app.

Postico bietet eine intuitive Oberfläche zum Erstellen und Bearbeiten von Tabellen.
Selbstverständlich gibt es aber auch einen mächtigen SQL Editor für komplexere Abfragen.


Um mit Postgres.app zu verbinden, ist keine Konfiguration notwendig. Klicke einfach auf "Connect".

## pgAdmin

<a href="http://pgadmin.org/" style="float:right;min-height:110px;">
<img src="http://www.postgresql.org/media/img/about/press/elephant.png" alt="PostgreSQL logo" style="width: 110px;margin: 0 10px;">
</a>

[pgAdmin](http://pgadmin.org) ist ein Open Source client mit vielen, vielen Funktionen.

Um mit Postgres.app zu verbinden, musst du zuerst eine neue Verbindung erstellen. Klicke dazu auf das Steckdosensymbol links oben.


Das einzige notwendige Feld ist "Name". Ich schlage "Postgres.app" vor.
Die restlichen Felder sollten standardmäßig schon richtig ausgefüllt sein (Siehe oben).
Bestätige mit "OK".

Um zu verbinden musst du dann die Verbindung in der Seitenleiste doppelklicken.


## Weitere Programme

In den letzten Jahren hat sich für Postgres-User am Mac viel getan:
Wie gesagt gibt es mittlerweile eine beachtliche Anzahl an Clients.
Eine ausführliche Übersicht über verfügbare Programme findest du im PostgreSQL Wiki: [Community Guide to PostgreSQL GUI Tools](https://wiki.postgresql.org/wiki/Community_Guide_to_PostgreSQL_GUI_Tools) (Englisch).

Hier sind Links zu allen Mac-Clients die ich finden konnte (in alphabetischer Reihenfolge):

- [Datagrip](https://www.jetbrains.com/datagrip/)
- [Datazenit](https://datazenit.com/)
- [DBeaver](http://dbeaver.jkiss.org/)
- [DbVisualizer](https://www.dbvis.com/)
- [Navicat for PostgreSQL](http://www.navicat.com/products/navicat-for-postgresql)
- [pgAdmin](http://pgadmin.org/)
- [PG Commander](https://eggerapps.at/pgcommander/)
- [PostgreSQL Manager](https://itunes.apple.com/at/app/postgresql-manager/id875191518?mt=12)
- [Postico](https://eggerapps.at/postico/)
- [PSequel](http://www.psequel.com)
- [SQLPro for PostgreSQL](http://www.hankinsoft.com/SQLProPostgres/)
- [Toad Mac Edition](https://itunes.apple.com/app/toad/id747961939?l=en&mt=12)
- [Valentina Studio](http://www.valentina-db.com/en/valentina-studio-overview)
- [Woolly](http://woollyapp.com)
- [DBGlass](http://dbglass.web-pal.com)


In den meisten Clients angeben musst du folgende Parameter angeben um mit Postgres.app zu verbinden:

- **Host:** localhost
- **Port:** 5432 (default)
- **Benutzer:** *dein lokaler Benutzername*
- **Passwort:** *leer*
- **Datenbank:** *gleich wie Benutzername*

Falls du eine Verbindungs-URL angeben musst: `postgresql://BENUTZERNAME@localhost/BENUTZERNAME`

