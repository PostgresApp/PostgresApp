---
layout: documentation
title: Installation, Upgrade und Deinstallation von Postgres.app
---

## Postgres.app installieren

Ziehe Postgres.app einfach in den Ordner Programme um es zu installieren.

Du kannst Postgres.app auch von anderen Orten starten, dann kann es aber sein, dass 
[gewisse Funktionalitäten nicht wie gewohnt zur Verfügung stehen](relocation-warning.html).

Wenn du von der Kommandozeile aus arbeiten willst, solltest du deinen `$PATH` konfigurieren. 
Am einfachsten geht das mit:

```bash
sudo mkdir -p /etc/paths.d && echo /Applications/Postgres.app/Contents/Versions/latest/bin | sudo tee /etc/paths.d/postgresapp
```

Für Details siehe [Command Line Tools](cli-tools.html).

Natürlich gibt es aber auch [graphische Clients für PostgreSQL](gui-tools.html).

### Wichtige Verzeichnise

- Binaries: `/Applications/Postgres.app/Contents/Versions/latest/bin`
- Header: `/Applications/Postgres.app/Contents/Versions/latest/include`
- Bibliotheken: `/Applications/Postgres.app/Contents/Versions/latest/lib`
- Datenverzeichnis (data directory): `~/Library/Application Support/Postgres/var-XX` (XX ist die Major-Version von PostgreSQL)

## Postgres.app deinstallieren

1. Postgres.app beenden und in den Papierkorb ziehen
2. (Optional) Datenverzeichnisse in den Papierkorb ziehen (Standardort: `~/Library/Application Support/Postgres`)
4. (Optional) Einstellungen und Konfiguration löschen:  
   `defaults delete com.postgresapp.Postgres2`
5. (Optional) Die Konfigurationsdatei für den `$PATH` löschen:  
   `sudo rm /etc/paths.d/postgresapp`

