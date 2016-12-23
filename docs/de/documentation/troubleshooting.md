---
layout: documentation
title: Fehlerbehebung
---

## Fehlerbehebung

### Häufige Fehlermeldungen

Die folgende Liste enthält alle Fehlermeldungen die bei der Benutzung von Postgres.app auftreten können. 

#### The binaries for this PostgreSQL server were not found
Sämtliche PostgreSQL Binärdateien sind im Bundle von Postgres.app enthalten (Versionen 9.5 und 9.6).

Dieser Fehler bedeutet, dass die Binärdateien nicht gefunden wurden. Das kann passieren, wenn eine zukünftige Version von Postgres.app die Server-Version deiner Datenbank nicht mehr enthält.
Die Fehlermeldung kann außerdem auftreten, wenn du ältere Binaries manuell hinzufügst und die App danach updatest.

Um diesen Fehler zu beseitigen musst du sicherstellen, dass sich die richtigen Binärdateien in diesem Ordner befinden: `/Applications/Postgres.app/Contents/Versions/`

#### Port [number] is already in use
Dieser Fehler bedeutet, dass bereits ein anderer PostgreSQL-Server auf deinem Mac läuft.
Du musst zuerst den alten Server deinstallieren und danach Postgres.app neu starten.

Der Fehler kann auch auftreten, wenn ein anderer User deines Macs Postgres.app bereits installiert hat.

Wenn du mehrere PostgreSQL Server gleichzeitig starten willst, muss jeder Server einen anderen Port verwenden (ein Port kann nur von einem Server gleichzeitig verwendet werden).

#### There is already a PostgreSQL server running in this data directory
Dieser Fehler kann auftreten, wenn deine Data Directory von einer anderen PostgreSQL-Installation verwendet wird.
Dazu musst du den anderen Server stoppen, bevor du Postgres.app öffnest.
Es ist nicht empfehlenswert, eine Data Directory einer anderen PostgreSQL zu verwenden, da diese anders konfiguriert sein kann und dies zu weiteren Fehlern führen kann.

#### The data directory contains an old postmaster.pid file / The data directory contains an unreadable postmaster.pid file
PostgreSQL erstellt eine Datei namens `postmaster.pid` im Data Directory. Diese Datei enthält die aktuelle Prozess-ID des PostgreSQL Servers.
Wenn der Server unerwartet beendet wird, kann diese Datei noch die ID des abgestürzten Prozesses enthalten, was dann zu diesem Fehler führt.
In diesem Fall musst du die Datei `postmaster.pid` löschen bevor du den Server startest; stelle aber sicher dass der Server nicht läuft!
Öffne dazu die Aktivitätsanzeige und stelle sicher, dass keine Prozesse namens ‘postgres‘ oder ‘postmaster‘ laufen.

Achtung: Wenn du die Datei `postmaster.pid` löschst während der Server läuft, können unangenehme Dinge passieren!

#### Could not initialize database cluster
Dieser Fehler bedeutet, dass der Befehl `initdb` nicht erfolgreich war. Dies sollte im Normalfall nicht passieren; wenn doch, eröffne ein neues Issue auf Github.
Zur Fehlersuche kannst du den folgenden Befehl manuell ausführen:

    /Applications/Postgres.app/Contents/Versions/latest/bin/initdb -D "DATA DIRECTORY" -U postgres --encoding=UTF-8 --locale=en_US.UTF-8

#### Could not create default user  / Could not create user database
Nachdem die Data Directory initialisiert wurde, erstellt Postgres.app einen Standard-User und eine Datenbank. Dieser Fehler bedeutet, dass hierbei etwas schief gelaufen ist. Weitere Infos findest du im Server-Log (diese Datei befindet sich im Data Directory).

Du kannst versuchen, den Standard-User und die Datenbank manuell zu erstellen:

    /Applications/Postgres.app/Contents/Versions/latest/bin/createuser -U postgres -p PORT --superuser USERNAME
    /Applications/Postgres.app/Contents/Versions/latest/bin/createdb -U USERNAME -p PORT DATABASENAME

#### File [or Folder] not found. It will be created the first time you start the server.
Data Directories und die darin enthaltenen Dateien werden erst erstellt, wenn der Server das erste mal gestartet wird.
Dieser Fehler tritt auf, wenn du in den Server Settings die Data Directory oder Dateien öffnen willst, diese aber noch nicht existieren.
Starte zuerst den Server und versuche es erneut.

#### Unknown Error
Dieser Fehler sollte nicht auftreten! Falls doch, schicke uns bitte eine detaillierte Beschreibung, wie es dazu kam.



### Fehler in der Server-Logdatei

Die Logdatei befindet sich im Data Directory und heißt `postgres-server.log`.
Hier sind die häufigsten Fehler:

#### Could not create listen socket for "localhost"  
Dieser Fehler wird normalerweise durch eine beschädigte `/etc/hosts`-Datei ausgelöst.
Die häufigsten Ursachen sind zB ein fehlender `localhost`-Eintrag, Syntax-Errors oder falsche Leerzeichen.

Unter macOS sieht die Datei folgendermaßen aus:

	##
	# Host Database
	#
	# localhost is used to configure the loopback interface
	# when the system is booting.  Do not change this entry.
	##
	127.0.0.1	localhost
	255.255.255.255	broadcasthost
	::1             localhost 


#### database files are incompatible with server: The database cluster was initialized with PG_CONTROL_VERSION x, but the server was compiled with PG_CONTROL_VERSION y
Dieser Fehler tritt üblicherweise auf, wenn du einen Server starten willst, welcher mit einer Prerelease-Version von PostgreSQL erstellt wurde.
(Das Datenformat wird manchmal zwischen zwei Prerelease-Versionen geändert.)
In diesem Fall musst du den Server mit der selben Version starten, mit welcher er erstellt wurde.
Danach kannst deine Datenbanken exportieren (dump), einen neuen Server mit der aktuellen Version erstellen und die Datenbanken wieder importieren (restore).


### Fehler beim Verbinden mit dem PostgreSQL server

#### psql: FATAL: role "USERNAME" does not exist
Normalerweise erstellt Postgres.app einen PostgreSQL-Benutzer mit demselben Name wie dein macOS-Benutzername.
Wenn dieser Fehler auftritt, existiert dieser PostgreSQL-Benutzer nicht.
Du kannst ihn aber einfach erstellen:

1. Stelle sicher, dass dein [$PATH richtig konfiguriert ist](cli-tools.html)
2. Führe den Befehl `createuser -U postgres -s $USER` im Terminal aus

Was bedeuted dieser Befehl?

- `-U postgres` ist der Benutzername mit dem wir verbinden
- `-s` bedeutet das wir einen Superuser erstellen wollen
- `$USER` ist der Name des PostgreSQL-Benutzers, den wir erstellen wollen (gleich wie macOS-Benutzername)

#### psql: FATAL: database "USERNAME" does not exist
Standardmäßig versucht psql mit einer Datenbank zu verbinden, die den selben Namen wie dein System-Benutzer hat.
Dieser Fehler bedeutet, dass diese Datenbank nicht existiert.
Das kann mehrere Gründe haben:

- Postgres.app konnte diese Datenbank beim initialisieren nicht erstellen
- Die Datenbank wurde gelöscht
- Dein Benutzername hat sich geändert

Du kannst das Problem folgenderweise beheben:

1. Stelle sicher, dass dein [$PATH richtig konfiguriert ist](cli-tools.html)
2. Erstelle die fehlende Datenbank einfach mit `createdb $USER`, oder
3. Verbinde mit einer anderen Datenbank, zB. `psql postgres`


#### Could not translate host name "localhost", service "5432" to address: nodename nor servname provided, or not known
Dieser Fehler wird normalerweise durch eine beschädigte `/etc/hosts`-Datei ausgelöst.
Die häufigsten Ursachen sind zB ein fehlender `localhost`-Eintrag, Syntax-Errors oder falsche Leerzeichen.

Unter macOS sieht die Datei folgendermaßen aus:

	##
	# Host Database
	#
	# localhost is used to configure the loopback interface
	# when the system is booting.  Do not change this entry.
	##
	127.0.0.1	localhost
	255.255.255.255	broadcasthost
	::1             localhost 


#### FATAL:  could not open relation mapping file "global/pg_filenode.map": No such file or directory
Dieser Fehler kann auftreten, wenn du das Datenverzeichnis löscht, während der Server noch läuft.
Bitte stoppe alle `postgres`-Prozesse. Am einfachsten geht das in dem du den Computer neu startest.
Dann starte einen neuen PostgreSQL Server.



### Manuelles Starten des Servers

Zum Debuggen ist es oft hilfreich, den Server über die Kommandozeile zu starten:

1. Beende Postgres.app
2. Gib den Befehl `/Applications/Postgres.app/Contents/Versions/latest/bin/postgres -D "DATA DIRECTORY" -p PORT` im Terminal ein. Ersetze DATA DIRECTORY mit dem Pfad deines Data Directorys und stelle sicher dass du den Pfad unter Anführungszeichen angibst (falls dieser Leerzeichen beinhaltet).
3. Jetzt solltest du genaue Fehlermeldungen erhalten

### Postgres.app zurücksetzen
Wenn dir auch der manuelle Start nicht weiter hilft, kannst du versuchen, den Server zurückzusetzen.  
***ACHTUNG: Dadurch werden sämtliche Datenbanken, Tabellen und darin enthaltene Daten gelöscht!***

1. Beende Postgres.app
2. Öffne die Aktivitätsanzeige und stelle sicher, dass keine Prozesse namens `postgres` laufen. Fall doch, musst du diese beenden. Dazu muss jener Prozess mit der kleinsten ID gestoppt werden; dadurch werden auch sämtliche Unterprozesse beendet.
3. Lösche den Ordner `~/Library/Application Support/Postgres`
4. Setze alle Einstellungen mit diesem Befehl zurück: `defaults delete com.postgresapp.Postgres2`
5. Starte Postgres.app

### Technischer Support

Wenn du Probleme mit Postgres.app hast, findest du Hilfe bei [Github Issues](https://github.com/postgresapp/postgresapp/issues).
Du kannst auch twittern: [@PostgresApp](https://twitter.com/PostgresApp).

### Hilf anderen

Falls du die Lösung für ein Problem findest, hilf uns und schreib's gleich in die Dokumentation!
Diese Dokumentation findest du auch auf Github.



