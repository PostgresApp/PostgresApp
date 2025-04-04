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

Unfortunately, PostgreSQL can only link with a specific version of Python until PostgreSQL 18.
Please install the correct version of Python, depending on the PostgreSQL version you are using:

<style>
  .documentation table {
    border-collapse: collapse;
    border: 1px solid #999;
    margin: 2em 0;
  }
  .documentation table td, .documentation table th {
    border: 1px solid #999;
    padding: 0.5em 1em;
  }
</style>

| PostgreSQL Version | Python Version                                                           |
| ------------------ | ------------------------------------------------------------------------ |
| PostgreSQL 18      | Python >= 3.9.x from [python.org](https://www.python.org/downloads/macos/) |
| PostgreSQL 17      | Python 3.13.x from [python.org](https://www.python.org/downloads/macos/) |
| PostgreSQL 16      | Python 3.12.x from [python.org](https://www.python.org/downloads/macos/) |
| PostgreSQL 15      | Python 3.11.x from [python.org](https://www.python.org/downloads/macos/) |
| PostgreSQL 14      | Python 3.9.x from [python.org](https://www.python.org/downloads/macos/)  |
| PostgreSQL 13      | Python 3.8.x from [python.org](https://www.python.org/downloads/macos/)  |
| PostgreSQL 12 and earlier | Python 2.7 (included with macOS)                                  |

PostgreSQL 18 supports linking with any Python version >= 3.2 loaded from `/Library/Frameworks/Python.framework`.
The packages from python.org provide symlinks at this location since version 3.9. These point to another symlink,
`/Library/Frameworks/Python.framework/Versions/Current`, which can be changed to the preferred Python version with
something like `sudo ln -svih 3.12 /Library/Frameworks/Python.framework/Versions/Current` after the corresponding
package has been installed. 

Installing or linking `Python.framework`s to `/Library/Frameworks/` from other sources like homebrew
should work as well, but is not tested nor supported:
`sudo ln -s /opt/homebrew/Frameworks/Python.framework /Library/Frameworks/`

Make sure to install the correct version of Python, then use the SQL command `CREATE EXTENSION plpython3u;` to enable the extension.
