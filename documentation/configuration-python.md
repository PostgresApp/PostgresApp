---
layout: documentation
title: Configuring Python for Postgres.app
---

Install the `psycopg2` library with with `pip install psycopg2` or add it to your pip requirements file.

## [Django](http://www.djangoproject.com/)

In your `settings.py`, add an entry to your `DATABASES` setting:

``` python
DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.postgresql_psycopg2",
        "NAME": "[YOUR_DATABASE_NAME]",
        "USER": "[YOUR_USER_NAME]",
        "PASSWORD": "",
        "HOST": "localhost",
        "PORT": "",
    }
}
```

## [Flask](Flask)

When using the [Flask-SQLAlchemy](http://packages.python.org/Flask-SQLAlchemy/)
extension you can add to your application code:

``` python
from flask import Flask
from flask.ext.sqlalchemy import SQLAlchemy

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://localhost/[YOUR_DATABASE_NAME]'
db = SQLAlchemy(app)
```

## [SQLAlchemy](http://www.sqlalchemy.org/)

In your application code add:

``` python
from sqlalchemy import create_engine
engine = create_engine('postgresql://localhost/[YOUR_DATABASE_NAME]')
```
