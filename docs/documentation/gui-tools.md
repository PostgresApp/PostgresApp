---
layout: documentation
title: GUI Tools for PostgreSQL on the Mac
---

If you prefer a graphical client to the command line, there are a number of choices for the Mac.
This page describes how to connect to Postgres.app with some popular clients.


## Postico

<a href="https://eggerapps.at/postico/" style="float:right;">
<img src="https://eggerapps.at/postico/img/icon_256x256.png" alt="Postico App Icon" style="width: 128px;height:128px;">
</a>

[Postico](https://eggerapps.at/postico/) is a modern Postgres client for OS X
— written by Jakob Egger, who also happens to be the maintainer of Postgres.app.

Postico features a beautiful interface for creating tables and working with data.
For complex queries it also includes a powerful SQL editor.

To connect with Postgres.app, there's no configuration necessary. Just click "Connect".



## pgAdmin

<a href="http://pgadmin.org/" style="float:right;min-height:110px;">
<img src="http://www.postgresql.org/media/img/about/press/elephant.png" alt="PostgreSQL logo" style="width: 110px;margin: 0 10px;">
</a>

[pgAdmin](http://pgadmin.org) is the official Open Source database client for PostgreSQL.

To connect to Postgres.app, you have to first create a new connection by clicking the "Add new Connection" icon (top left icon of an electric plug).

The only field you have to provide is "Name".
You can choose any name, I suggest "Postgres.app".
You can leave default values for "host", "port" and "user".
Click "OK" to save.

To actually connect, double click the newly created connection in the sidebar.



## More Applications

There are many clients for PostgreSQL on the Mac.
You can find many of them in the [Community Guide to PostgreSQL GUI Tools](https://wiki.postgresql.org/wiki/Community_Guide_to_PostgreSQL_GUI_Tools) in the PostgreSQL wiki.
Some of them are quite powerful; some are still a bit rough.
Here's a list of all the Mac Apps I found (in alphabetic order):

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
- [Toad Mac Edition](https://itunes.apple.com/app/toad/id747961939?l=en&mt=12)
- [SQLPro for PostgreSQL](http://www.hankinsoft.com/SQLProPostgres/)
- [Valentina Studio](http://www.valentina-db.com/en/valentina-studio-overview)
- [Woolly](http://woollyapp.com)
- [DBGlass](http://dbglass.web-pal.com)


Most GUI applications will expect you to provide the following connection parameters to connect to Postgres.app:

- **Host:** localhost
- **Port:** 5432 (default)
- **User:** *your user name*
- **Password:** *blank*
- **Database:** *same as user name*

If you need to provide an URL, use `postgresql://YOURUSERNAME@localhost/YOURUSERNAME`


