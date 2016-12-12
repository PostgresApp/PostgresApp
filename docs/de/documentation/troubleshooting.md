---
layout: documentation.de
title: Fehlerbehebung
---

## Fehlerbehebung

### Häufige Fehlermeldungen

Die folgende Liste enthält alle Fehlermeldungen die bei der Benutzung von Postgres.app auftreten können. 

#### The binaries for this PostgreSQL server were not found
Postgres.app benötigt mehrere Binärdateien um reibungslos zu funktionieren. Dieser Error tritt auf wenn ein oder mehrere Binaries nicht gefunden werden.
Um den Fehler zu beseitigen musst du einen neuen Server mit der selben Portnummer und Data Directory erstellen. Versuch danach erneut, den Server zu starten.

#### Port [number] is already in use
Dieser Fehler tritt auf wenn der angegebene Port bereits von einem anderen Server verwendet wird.
Ändere entweder die Portnummer oder stoppe den Server, der diesen Port gerade benutzt.

#### There is already a PostgreSQL server running in this data directory
Jede Data Directory kann nur von einem Server zur selben Zeit benutzt werden. Dieser Fehler triff auf, wenn dein Server auf eine Data Directroy zugreifen will, die bereits in Verwendung ist.
Um fortfahren zu können musst du den anderen Server zuerst beenden.

#### The data directory contains an old postmaster.pid file / The data directory contains an unreadable postmaster.pid file
Jede Data Directory enthält eine postmaster.pid Datei, welche die Prozess ID des jeweiligen Servers beinhaltet.
Öffne die Aktivitäts Anzeige, suche nach dem Prozess mit dieser ID und beende diesen Prozess mitsamt allen Kind-Prozessen.
Jetzt solltest du deinen Server starten können.

#### Could not initialize database cluster / Could not create default user  / Could not create user database
Wenn ein neuer Server das erste mal gestartet wird erzeugt Postgres.app zunächst ein neues Datenbank Cluster sowie einen User und eine User Datenbank.
Dieser Fehler bedeutet dass das Datenbank Cluster / der User / die User Datenbank nicht erstellt werden konnte.
Erstelle einen neuen Server und versuche es erneut.

#### File [or Folder] not found. It will be created the first time you start the server.
Die Data Directories und sämtliche Datendateien werden erst erstellt wenn du den Server das erste mal startest.
Dieser Fehler tritt auf, wenn du die Data Directories oder Dateien öffnen willst, diese aber noch nicht existieren.
Starte zuerst den Server und versuche es erneut.

#### Unknown Error
Dieser Fehler sollte idR nicht auftreten.
Falls doch, schicke und bitte eine detaillierte Beschreibung, wie es dazu kam.



### Schau in die Logdatei

Postgres.app speichert ab Version 9.3.5.1 das Server-Log im Datenverzeichnis. Die Logdatei heißt `postgres-server.log`.

### Starte den Server manuell

Zum debuggen ist es oft praktisch, den Server über die Kommandozeile zu starten:

1. Klicke auf den Button 'Server Settings' und ermittle dein Datenverzeichnis (Data Directory)<br>(Standard für Version 9.6: `/Users/USERNAME/Library/Application Support/Postgres/var-9.6`)
2. Stoppe den Server
3. Öffne das Terminal und schreibe `/Applications/Postgres.app/Contents/Versions/9.6/bin/postgres -D "DATA_DIRECTORY"`<br>Passe ggf. die Versionsnummer an und ersetze DATA_DIRECTORY mit dem Pfad deines Datenverzeichnisses. (Die Anführungszeichen werden aufgrund der Leerzeichen im Pfad benötigt.)
4. Jetzt solltest du genaue Fehlermeldungen erhalten

### Postgres.app zurücksetzen

Wenn dir auch der manuelle Start nicht weiter hilft, kannst du versuchen, den Server zurückzusetzen.<br>
***ACHTUNG: Dadurch werden sämtliche Datenbanken, Tabellen und darin enthaltene Daten gelöscht!***

1. Beende Postgres.app
2. Öffne die Aktivitätsanzeige. Falls Prozesse names `postgres` laufen, beende sie. Beende zuerst den Prozess mit der niedrigsten pid; ansonsten werden die Prozesse automatisch neu gestartet.
3. Lösche das Verzeichnis `~/Library/Application Support/Postgres` (Vorsicht: da sind womöglich all deine Daten drin)
4. Öffne Postgres.app 
5. Nach kurzer Zeit sollte ein nagelneuer, leerer Cluster initialisiert sein

### Support

Wenn du Probleme hast mit Postgres.app, findest du Hilfe bei [Github Issues](https://github.com/postgresapp/postgresapp/issues).
Du kannst es auch über Twitter versuchen: [@PostgresApp](https://twitter.com/PostgresApp).

### Hilf anderen

Falls du die Lösung für ein Problem findest, hilf uns und schreib's gleich in die Dokumentation!
Diese Dokumentation findest du [auch auf Github](https://github.com/PostgresApp/postgresapp.github.io/tree/master/documentation).

### Lade die neuste Version von Postgres.app

Vergewissere dich auf Github unter [Releases](https://github.com/PostgresApp/PostgresApp/releases) ob du tatsächlich die aktuellste Version verwendest.

