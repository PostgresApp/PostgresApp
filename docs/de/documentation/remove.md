---
layout: documentation
title: Andere PostgreSQL Installationen entfernen
---

## Andere PostgreSQL Installationen entfernen

Postgres.app kann nicht starten wenn schon ein anderer Server am selben Port läuft (Standardport: 5432).
Wir empfehlen andere PostgreSQL-Installationen zu entfernen bevor der Installation von Postgres.app.

Bevor du PostgreSQL deinstallierst, stelle sicher dass du ein Backup der Daten mit `pg_dump` erstellt hast.

Nach dem Deinstallieren, öffne die „Aktivitätsanzeige“ und suche nach Prozessen mit dem Namen “postgres” oder “postmaster”.
Wenn solche Prozesse noch laufen, kann Postgres.app wahrscheinlich nicht starten.
Starte deinen Mac neu um diese Prozesse loszuwerden.

### Homebrew

``` bash
$ brew remove postgresql
````

### MacPorts

Verwende den Befehl `installed` um zu bestimmen welche Version du installiert hast:

``` bash
$ sudo port installed
```

Dann deinstalliere den Server. Zum Beispiel für Version 9.4 gib ein:

``` bash
$ sudo port uninstall postgresql94-server
```

Nach der Deinstallation könnte der Server noch laufen. Starte deinen Mac neu um sicherzugehen dass PostgreSQL nicht mehr läuft.

### EnterpriseDB

EnterpriseDB kommt mit einem automatischen Uninstaller, den du im Installationsverzeichnis finden kannst.

Das Standardinstallationsverzeichnis ist `/Library/PostgreSQL`. Dieses Verzeichnis kannst du mit dem Befehl “Gehe zum Ordner…” im Finder öffnen (⌘⇧G).

Ein Doppelklick auf das Programm “uninstall-postgresql” sollte dann genügen.

### Kyng Chaos

Mehr Infos zur Kyng Chaos Ditstribution findest du [hier](http://comments.gmane.org/gmane.comp.gis.postgis/32157).
