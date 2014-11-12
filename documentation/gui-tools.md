---
layout: documentation
title: GUI Tools for PostgreSQL on the Mac
---

If you prefer a graphical client to the command line, there are a number of choices for the Mac.
This page describes how to connect to Postgres.app with some popular clients.

## Generic Settings

There are many clients for PostgreSQL on the Mac.
You can find many of them in the [Community Guide to PostgreSQL GUI Tools](https://wiki.postgresql.org/wiki/Community_Guide_to_PostgreSQL_GUI_Tools) in the PostgreSQL wiki.

These are the connection parameters you will need to provide for most GUI applications:

- **Host:** localhost
- **Port:** 5432 (default)
- **User:** *your user name*
- **Password:** *blank*
- **Database:** *same as user name*

If you need to provide an URL, use `postgresql://YOURUSERNAME@localhost/YOURUSERNAME`


## pgAdmin

[pgAdmin](http://pgadmin.org) is an Open Source database client with lots and lots of features.

To connect to Postgres.app, you have to first create a new connection by clicking the "Add new Connection" icon (top left icon of an electric plug).

The only field you have to provide is "Name". You can choose any name, I suggest "Postgres.app". Make sure that host, port, and user name are filled in as above, then click "OK" to save.

To actually connect, double click the newly created connection in the sidebar.

## PG Commander

[PG Commander](https://eggerapps.at/pgcommander/) is the easiest client to connect to Postgres.app: Just click "Connect".
The default settings are already suitable for connecting to Postgres.app.

PG Commander is written by Jakob Egger, the current maintainer of Postgres.app.

## Induction

Explore, Query, Visualize: [Induction](http://inductionapp.com) is a database app that supports different databases, and also PostgreSQL.
It has built in support for graphing query results.

To connect to Postgres.app with Induction, you need to provide an URL:

    postgresql://YOURUSERNAME@localhost/YOURUSERNAME

Induction is written by Mattt Thompson, the creator of Postgres.app.
