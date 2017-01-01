---
layout: documentation
title: Installing, Upgrading and Uninstalling Postgres.app
---

## Installing Postgres.app

To install Postgres.app, just drag it to your Applications folder and double click.

Postgres.app must be placed in the /Applications folder, and you can't rename it.
The reason for this is that it includes a lot of dynamic libraries that can be used by other software.
These libraries can't be found if you change the path.

If you'd like to use the command line tools delivered with Postgres.app, execute the following command in Terminal to configure your `$PATH`, and then close & reopen the window:

```bash
sudo mkdir -p /etc/paths.d && echo /Applications/Postgres.app/Contents/Versions/latest/bin | sudo tee /etc/paths.d/postgresapp
```

For more details, see the [section on Command Line Tools](cli-tools.html).


### Installation Directories

- Binaries: `/Applications/Postgres.app/Contents/Versions/latest/bin`
- Headers: `/Applications/Postgres.app/Contents/Versions/latest/include`
- Libraries: `/Applications/Postgres.app/Contents/Versions/latest/lib`
- Default data directory: `~/Library/Application Support/Postgres/var-9.6`



## Uninstalling Postgres.app

1. Quit Postgres.app & drag it to the Trash
3. Delete the data directory (default location: `~/Library/Application Support/Postgres`)
4. Delete preferences for Postgres.app by executing the following command:  
   `defaults delete com.postgresapp.Postgres2`
5. Remove the `$PATH` config for the command line tools (optional):  
   `sudo rm /etc/paths.d/postgresapp`