---
layout: documentation.de
title: Fehlerbehebung
---

### Lade die neuste Version von Postgres.app

Sie auf Github bei den [Releases](https://github.com/PostgresApp/PostgresApp/releases) nach ob du tatsächlich die aktuellste Version verwendest.

### Schau in die Logdateien

Postgresapp 9.3.5.1 und neuer speichern das Server-Log im Datenverzeichnis. Die Logdatei heißt `postgres-server.log`.

### Starte den Server manuell

Zum debuggen ist es oft praktisch, den Server von der Kommandozeile zu starten:

1. Sie in den Preferences nach was dein Datenverzeichnis ist<br>(Standard: `/Users/USERNAME/Library/Application Support/Postgres/var-9.3`)
2. Beende Postgres.app
3. Öffne das Terminal und schreibe `/Applications/Postgres.app/Contents/Versions/9.3/bin/postgres -D "DATA_DIRECTORY"` (ersetze DATA_DIRECTORY mit dem Pfad deines Datenverzeichnisses, die Anführungszeichen sind notwendig wegen den Leerzeichen im Pfad)
4. Jetzt solltest du genaue Fehlermeldungen erhalten warum etwas nicht funktioniert

### Postgres.app zurücksetzen

Manchmal ist ein neuer Start das einzige was einen aus einer misslichen Lage befreien kann:

1. Beende Postgres.app
2. Öffne die Aktivitätsanzeige. Falls Prozesse names `postgres` laufen, beende sie. Beende zuerst den Prozess mit der niedrigsten pid; ansonsten werden die Prozesse automatisch neu gestartet.
3. Lösche das Verzeichnis `~/Library/Application Support/Postgres` (Vorsicht: da sind womöglich all deine Daten drin)
4. Öffne Postgres.app 
5. Nach kurzer Zeit sollte ein nagelneuer, leerer Cluster initialisiert sein

### Support

Wenn du Probleme hast mit Postgres.app, findest du Hilfe bei [Github Issues](https://github.com/postgresapp/postgresapp/issues).
Du kannst es auch über Twitter versuchen: [@PostgresApp](https://twitter.com/PostgresApp).

### Hilf anderen

Falls du die Lösung für ein Problem findest, hilf uns!
Schreib's gleich in die Dokumentation!
Diese Dokumentation findest du [auch auf Github](https://github.com/PostgresApp/postgresapp.github.io/tree/master/documentation).

