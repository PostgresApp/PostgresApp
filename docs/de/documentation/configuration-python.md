---
layout: documentation
title: Postgres.app mit Python verwenden
---

Um PostgreSQL zu verwenden, installiere zuerst die psycopg2-Bibliothek mit `pip install psycopg2`

## [Django](http://www.djangoproject.com/)

Füge einen Eintrag zur Konfigurationsdatei `settings.py` im Bereich `DATABASES` dazu:

``` python
DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.postgresql_psycopg2",
        "NAME": "[DATENBANK_NAME]",
        "USER": "[YOUR_USER_NAME]",
        "PASSWORD": "",
        "HOST": "localhost",
        "PORT": "",
    }
}
```

## [Flask-SQLAlchemy](http://packages.python.org/Flask-SQLAlchemy/)

``` python
from flask import Flask
from flask.ext.sqlalchemy import SQLAlchemy

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://localhost/[DATENBANK_NAME]'
db = SQLAlchemy(app)
```

## [SQLAlchemy](http://www.sqlalchemy.org/)

``` python
from sqlalchemy import create_engine
engine = create_engine('postgresql://localhost/[DATENBANK_NAME]')
```
