---
layout: documentation
title: Using PL/Python with Postgres.app
---

## PL/Python

If you want to write stored procedures or functions in Python, you have to use PL/Python.

### PostgreSQL 13 and newer

Starting with PostgreSQL 13, Postgres.app includes the `plpython3u` extension.
This extension allows you to create functions and stored procedures in Python 3.
However, Postgres.app does not include the Python programming language itself.
You need to download the official Python installer separately.

1. Download and install Python 3.8.x (for PostgreSQL 13) and/or Python 3.9.x (universal2)
   (for PostgreSQL 14) from [python.org](https://www.python.org/downloads/macos/). 
   Other Python installations or versions are not supported.

2. Activate the `plpython3u` extension with the command `CREATE EXTENSION plpython3u;`

3. You can now create functions and procedures that use the language `plpython3u`.

Postgres.app with PostgreSQL 13 and newer does not support Python 2.7.

### PostgreSQL 12 and earlier

Postgres.app includes the `plpython2u` extension.
It links to Python 2.7, which is included in macOS.

1. Activate the `plpython2u` extension with the command `CREATE EXTENSION plpython2u;`

2. You can now create functions and procedures that use the language `plpython2u`.

