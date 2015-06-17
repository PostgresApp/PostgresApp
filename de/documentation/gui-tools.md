---
layout: documentation.de
title: GUI Tools für PostgreSQL am Mac
---

Mittlerweile gibt es eine beachtliche Auswahl an grafischen Clients für Postgres am Mac.
Eine ausführliche Übersicht über verfügbare Programme findest du im PostgreSQL Wiki: [Community Guide to PostgreSQL GUI Tools](https://wiki.postgresql.org/wiki/Community_Guide_to_PostgreSQL_GUI_Tools) (Englisch).

## Allgemeine Einstellungen

Folgende Infos musst du in den meisten Clients angeben:

- **Host:** localhost
- **Port:** 5432 (default)
- **Benutzer:** *dein lokaler Benutzername*
- **Passwort:** *leer*
- **Datenbank:** *gleich wie Benutzername*

Falls du eine Verbindungs-URL angeben musst: `postgresql://BENUTZERNAME@localhost/BENUTZERNAME`


## pgAdmin

[pgAdmin](http://pgadmin.org) ist ein Open Source client mit vielen, vielen Funktionen.

Um mit Postgres.app zu verbinden, musst du zuerst eine neue Verbindung erstellen. Klicke dazu auf das Steckdosensymbol links oben.


Das einzige notwendige Feld ist "Name". Ich schlage "Postgres.app" vor.
Die restlichen Felder sollten standardmäßig schon richtig ausgefüllt sein (Siehe oben).
Bestätige mit "OK".

Um zu verbinden musst du dann die Verbindung in der Seitenleiste doppelklicken.

## Postico

[Postico](https://eggerapps.at/postico/) ist ein sehr moderner und benutzerfreundlicher Client für OS X.
In Postico ist keine Konfiguration notwendig, klicke einfach auf "Connect".

Postico wird entwickelt von Jakob Egger, dem aktuellen Maintainer von Postgres.app.

