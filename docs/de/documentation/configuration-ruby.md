---
layout: documentation
title: Postgres.app mit Ruby verwenden
---


Zuallererst musst du das `pg` gem installieren. Stelle sicher, dass dein `$PATH` richtig konfiguriert ist (see [hier](cli-tools.html)), dann führ den folgenden Befehl aus:

    sudo ARCHFLAGS="-arch x86_64" gem install pg

## [Foreman](https://github.com/ddollar/foreman/)

Wenn du mit Foreman arbeitest, musst du die Variable `DATABASE_URL` in `.env` konfigurieren:

```
DATABASE_URL=postgres://postgres@localhost/[DATENBANK_NAME]
```

Mehr Infos zu Konfigurationsvariablen dazu findest du [im Heroku Dev Center](https://devcenter.heroku.com/articles/config-vars).

## [Rails](http://rubyonrails.org/)

Verwende folgende Einstellungen in `config/database.yml`:

``` yaml
development:
  adapter: postgresql
  database: [DATENBANK_NAME]
  host: localhost
```

## [Sinatra](http://www.sinatrarb.com/)

Schreib folgendes in `config.ru` (oder irgendwo in deinem Programmcode):

``` ruby
set :database, ENV['DATABASE_URL'] || 'postgres://localhost/[DATENBANK_NAME]'
```

## [ActiveRecord](http://ar.rubyonrails.org/)

Installiere das `activerecord` gem, verwende dann `require 'active_record'`.
Dann kannst du folgendermaßen verbinden:

``` ruby
ActiveRecord::Base.establish_connection(ENV["DATABASE_URL"])
```

## [DataMapper](http://datamapper.org/)

Installiere die `datamapper` und `do_postgres` gems, dann kannst du mit folgendem Befehl verbinden:

``` ruby
DataMapper.setup(:default, ENV['DATABASE_URL'] || "postgres://localhost/[DATENBANK_NAME]")
```

## [Sequel](http://sequel.rubyforge.org/)

Installiere und lade das `sequel` gem, dann verbinde mit folgendem Code:

``` ruby
DB = Sequel.connect(ENV['DATABASE_URL'] || "postgres://localhost/[DATENBANK_NAME]")
```

