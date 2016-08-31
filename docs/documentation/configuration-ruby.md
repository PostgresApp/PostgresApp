---
layout: documentation
title: Configuring Ruby for Postgres.app
---


To install the `pg` gem, make sure you have set up your `$PATH` correctly (see [Command-Line Tools](cli-tools.html)), then execute the following command:

    sudo ARCHFLAGS="-arch x86_64" gem install pg

If you are running your application with [Foreman](https://github.com/ddollar/foreman), set the `DATABASE_URL` config variable in `.env`:

```
DATABASE_URL=postgres://postgres@localhost/[YOUR_DATABASE_NAME]
```

You can learn more about environment variables from [this Heroku Dev Center article](https://devcenter.heroku.com/articles/config-vars).

## [Rails](http://rubyonrails.org/)

In `config/database.yml`, use the following settings:

``` yaml
development:
  adapter: postgresql
  database: [YOUR_DATABASE_NAME]
  host: localhost
```

## [Sinatra](http://www.sinatrarb.com/)

In `config.ru` or your application code:

``` ruby
set :database, ENV['DATABASE_URL'] || 'postgres://localhost/[YOUR_DATABASE_NAME]'
```

## [ActiveRecord](http://ar.rubyonrails.org/)

Install the `activerecord` gem and `require 'active_record'`, and establish a database connection:

``` ruby
ActiveRecord::Base.establish_connection(ENV["DATABASE_URL"])
```

## [DataMapper](http://datamapper.org/)

Install and require the `datamapper` and `do_postgres` gems, and create a database connection:

``` ruby
DataMapper.setup(:default, ENV['DATABASE_URL'] || "postgres://localhost/[YOUR_DATABASE_NAME]")
```

## [Sequel](http://sequel.rubyforge.org/)

Install and require the `sequel` gem, and create a database connection:

``` ruby
DB = Sequel.connect(ENV['DATABASE_URL'] || "postgres://localhost/[YOUR_DATABASE_NAME]")
```

