---
layout: documentation
title: Using PL/Python with Postgres.app
---

## PL/Python

PL/Python allows you to create stored procedures and functions in Python.

PL/Python is an *untrusted* language.
This means that only a superuser can create procedures with it, but other users can use them.
The default user created by Postgres.app is a superuser, so this shouldn't be an issue in most cases.

To use PL/Python with Postgres.app, you first need to install Python using the [installers from python.org](https://www.python.org/downloads/macos/).

Unfortunately, PostgreSQL can only link with a specific version of Python.
Please install the correct version of Python, depending on the PostgreSQL version you are using:

| PostgreSQL Version | Python Version                                                           |
| ------------------ | ------------------------------------------------------------------------ |
| PostgreSQL 16      | Python 3.12.x from [python.org](https://www.python.org/downloads/macos/) |
| PostgreSQL 15      | Python 3.11.x from [python.org](https://www.python.org/downloads/macos/) |
| PostgreSQL 14      | Python 3.9.x from [python.org](https://www.python.org/downloads/macos/)  |
| PostgreSQL 13      | Python 3.8.x from [python.org](https://www.python.org/downloads/macos/)  |
| PostgreSQL 12 and earlier | Python 2.7 (included with macOS)                                  |

Make sure to install the correct version of Python, then use the SQL command `CREATE EXTENSION plpython3u;` to enable the extension.
