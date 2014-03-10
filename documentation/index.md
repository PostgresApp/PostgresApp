---
layout: documentation
title: Postgres.app Documentation
---

Postgres.app is the easiest way to get started with PostgreSQL on the Mac. Open the app, and you have a PostgreSQL server ready and awaiting new connections. Close the app, and the server shuts down.

Whether you're a command line aficionado, prefer GUIs, or just want to start making things with your framework of choice, connecting to Postgres.app is easy.

## Upgrading From A Previous Version

Starting with Version 9.2.2.0, Postgres.app is using semantic versioning, tied to the release of PostgreSQL provided in the release, with the final number corresponding to the individual releases of PostgresApp for each distribution.

Upgrading between bugfix versions (eg. 9.3.0.0 to 9.3.1.0, or 9.3.1.0 to 9.3.1.1) is as simple as replacing Postgres.app in your Applications directory. Make sure that the app is closed, though.

When updating between minor PostgreSQL releases (eg. 9.3.x to 9.4.x), Postgres.app will create a new, empty data directory.
You are responsible for migrating the data yourself.
We suggest using `pg_dump_all` to export your data, and then import it using `psql`.

Starting with Version 9.3.2.0, the default the data directory is:
`~/Library/Application Support/Postgres/var-9.3`

## Command-Line Tools

`psql` is the PostgreSQL command-line interface to your database. Mac OS 10.7 ships with an older version of PostgreSQL, which can be started with the following command:

```bash
$ psql -h localhost
```

When Postgres.app first starts up, it creates the $USER database, which is the default database for `psql` when none is specified. The default user is $USER, with no password.

PostgreSQL ships with a constellation of useful binaries, like `pg_dump` or `pg_restore`, that you will likely want to use. Go ahead and add the `/bin` directory that ships with Postgres.app to your `PATH` (preferably in `.profile`, `.bashrc`, `.zshrc`, or the like to make sure this gets set for every Terminal session):

```bash
PATH="/Applications/Postgres.app/Contents/Versions/9.3/bin:$PATH"
```

Once your path is correctly set up, you should be able to run `psql` without a host. (If not, check that the correct version is being loaded in the `PATH` by doing `which psql`)

Postgres.app creates a PostgreSQL user with your current username ($USER). It also creates a database with this name, which will be the default one `psql` connects to if you don't specify otherwise.

To create a new database, connect with `psql` and enter the following:

```sql
CREATE DATABASE your_database_name;
```

To delete it, enter:

```sql
DROP DATABASE your_database_name;
```

You can get a list of all of `psql`'s commands and shortcuts with `\?`. A complete reference for PostgreSQL is [available on the PostgreSQL.org](http://www.postgresql.org/docs/9.1/interactive/index.html).

### Man pages

Postgres.app ships with man pages. If you've configured your `PATH` as described above, just type `man psql` to read the official docs.

## GUI Applications

Explore, query, and visualize your data with [Induction](http://inductionapp.com/). Although still in early development, Induction is fast and easy to use, and is our go-to application when working with data.

If you are running Mac OS X 10.8 and enjoy the cutting edge, check out [PG Commander](http://eggerapps.at/pgcommander/).

If you're looking for something more fully-featured and don't mind getting the kitchen sink in the process, check out [pgAdmin](http://www.pgadmin.org/).

### Connection parameters

When using a GUI program, here are the connection parameters you need to enter:

- **Host:** localhost
- **Port:** 5432 (default)
- **User:** *your user name*
- **Password:** *blank*
- **Database:** *same as user name*

If you need to provide an URL (eg. for Induction), use `postgresql://YOURUSERNAME@localhost/YOURUSERNAME`

## Configuration Settings

Building a web application and want to skip to the part where everything works? Select the connection settings for your language, framework, and library of choice:

### Ruby

Install the `pg` gem with `gem install pg`, or just add `gem 'pg'` to your application's `Gemfile` and run `bundle install`

If you are running your application with [Foreman](https://github.com/ddollar/foreman), set the `DATABASE_URL` config variable in `.env`:

```
DATABASE_URL=postgres://postgres@localhost/[YOUR_DATABASE_NAME]
```

You can learn more about environment variables from [this Heroku Dev Center article](https://devcenter.heroku.com/articles/config-vars).

#### [Rails](http://rubyonrails.org/)

In `config/database.yml`, use the following settings:

``` yaml
development:
  adapter: postgresql
  database: [YOUR_DATABASE_NAME]
  host: localhost
```

#### [Sinatra](http://www.sinatrarb.com/)

In `config.ru` or your application code:

``` ruby
set :database, ENV['DATABASE_URL'] || 'postgres://localhost/[YOUR_DATABASE_NAME]'
```

#### [ActiveRecord](http://ar.rubyonrails.org/)

Install the `activerecord` gem and `require 'active_record'`, and establish a database connection:

``` ruby
ActiveRecord::Base.establish_connection(ENV["DATABASE_URL"])
```

#### [DataMapper](http://datamapper.org/)

Install and require the `datamapper` and `do_postgres` gems, and create a database connection:

``` ruby
DataMapper.setup(:default, ENV['DATABASE_URL'] || "postgres://localhost/[YOUR_DATABASE_NAME]")
```

#### [Sequel](http://sequel.rubyforge.org/)

Install and require the `sequel` gem, and create a database connection:

``` ruby
DB = Sequel.connect(ENV['DATABASE_URL'] || "postgres://localhost/[YOUR_DATABASE_NAME]")
```

### Python

Install the `psycopg2` library with with `pip install psycopg2` or add it to your pip requirements file.

#### [Django](http://www.djangoproject.com/)

In your `settings.py`, add an entry to your `DATABASES` setting:

``` python
DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.postgresql_psycopg2",
        "NAME": "[YOUR_DATABASE_NAME]",
        "USER": "",
        "PASSWORD": "",
        "HOST": "localhost",
        "PORT": "",
    }
}
```

#### [Flask](Flask)

When using the [Flask-SQLAlchemy](http://packages.python.org/Flask-SQLAlchemy/)
extension you can add to your application code:

``` python
from flask import Flask
from flask.ext.sqlalchemy import SQLAlchemy

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://localhost/[YOUR_DATABASE_NAME]'
db = SQLAlchemy(app)
```

#### [SQLAlchemy](http://www.sqlalchemy.org/)

In your application code add:

``` python
from sqlalchemy import create_engine
engine = create_engine('postgresql://localhost/[YOUR_DATABASE_NAME]')
```

### PHP

#### [PDO](http://www.php.net/manual/en/book.pdo.php)

Make sure your PHP setup has PDO installed (it is enabled by default in PHP 5.1.0 or above), and the [PostgreSQL PDO driver](http://www.php.net/manual/en/ref.pdo-pgsql.php) is enabled. Then a database connection can be established with:

``` php
<?php
$dbh = new PDO('pgsql:host=localhost;dbname=[YOUR_DATABASE_NAME]');
?>
```

## Removing Existing PostgreSQL Installations

For best results, you should remove any existing installation of PostgreSQL. Here's a run-down of the most common ways you may have installed it previously:

### Homebrew

``` bash
$ brew remove postgresql
````

### MacPorts

``` bash
$ sudo port uninstall postgres
```

### EnterpriseDB

In the EnterpriseDB installation directory, open `uninstall-postgresql.app`.

## Included Packages

Each release of Postgres.app comes with the latest stable release of PostgreSQL, as well a few choice extensions. Here's a rundown of what's under the hood:

- [PostgreSQL](http://www.postgresql.org/)
- [PostGIS](http://postgis.refractions.net/)
- [plv8](http://code.google.com/p/plv8js/wiki/PLV8)

## Installation Directories

- Binaries: `/Applications/Postgres.app/Contents/Versions/9.3/bin`
- Headers: `/Applications/Postgres.app/Contents/Versions/9.3/include`
- Libraries: `/Applications/Postgres.app/Contents/Versions/9.3/lib`
- Man pages: `/Applications/Postgres.app/Contents/Versions/9.3/share`
- Default data directory: `~/Library/Application\ Support/Postgres/var-9.3`

## Uninstalling

Uninstall Postgres.app just like you would any application: quit, drag to the Trash, and Empty Trash.

Postgres.app data and configuration resides at `~/Library/Application\ Support/Postgres`, so remove that when uninstalling, or if you need to do a hard reset on the database.

## Troubleshooting

If you run into any issues using Postgres.app, your first stop should be the [issue tracker](https://github.com/postgresapp/postgresapp/issues) on Github.
You can also ask [@Postgresapp](https://twitter.com/Postgresapp) on Twitter.

## Additional Resources

- [PostgreSQL Website](http://www.postgresql.org/) - The source for all of the latest PostgreSQL news and information.
- [PostgreSQL Docs](http://www.postgresql.org/docs/9.2/interactive/index.html) - The canonical reference for everything you need to know about PostgreSQL.
- [Postgres Guide](http://postgresguide.com/) - A promising new PostgreSQL resource that reads well and introduces advanced topics in a way that's easy to understand.
- [Heroku Postgres](https://postgres.heroku.com/) - The largest and most reliable Postgres service in the world, for when it comes time to deploy and scale your database in production.
