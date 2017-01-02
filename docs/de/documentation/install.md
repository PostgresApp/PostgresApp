---
layout: documentation
title: Installation, Upgrade und Deinstallation von Postgres.app
---

## Postgres.app installieren

Ziehe Postgres.app einfach in den Ordner Programme um es zu installieren.

Postgres.app muss sich immer im Programme-Ordner befinden (in /Applications, nicht in einem benutzerspezifischen Ordner).
Ansonsten kann die Code-Signatur nicht überprüft werden.
Du musst es mit dem Finder in den Programme-Ordner bewegen - verwende nicht das Terminal.


Wenn du von der Kommandozeile aus arbeiten willst, solltest du deinen `$PATH` konfigurieren. 
Am einfachsten geht das mit:

```bash
sudo mkdir -p /etc/paths.d && echo /Applications/Postgres.app/Contents/Versions/latest/bin | sudo tee /etc/paths.d/postgresapp
```

Für Details siehe [Command Line Tools](cli-tools.html).

Natürlich gibt es aber auch [graphische Clients für PostgreSQL](gui-tools.html).

### Wichtige Verzeichnise

- Binaries: `/Applications/Postgres.app/Contents/Versions/9.6/bin`
- Header: `/Applications/Postgres.app/Contents/Versions/9.6/include`
- Bibliotheken: `/Applications/Postgres.app/Contents/Versions/9.6/lib`
- Datenverzeichnis (data directory): `~/Library/Application Support/Postgres/var-9.6`

## Postgres.app deinstallieren

1. Postgres.app beenden und in den Papierkorb ziehen
2. Datenverzeichnis in den Papierkorb ziehen (Standardort: `~/Library/Application Support/Postgres/var-9.5`)
4. Preferences löschen:  
   `defaults delete com.postgresapp.Postgres2`
5. Konfigurationsdatei für `$PATH` löschen (optional):  
   `sudo rm /etc/paths.d/postgresapp`

