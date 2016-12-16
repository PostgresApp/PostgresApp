---
layout: documentation
title: Postgres.app mit PHP verwenden
---

### PHP

#### [PDO](http://www.php.net/manual/de/book.pdo.php)

Du brauchst eine PHP-Installation mit PDO (Standard ab PHP 5.1.0) und mit dem [PostgreSQL PDO Treiber](http://www.php.net/manual/de/ref.pdo-pgsql.php).
Dann kannst du mit folgendem Befehl verbinden:

``` php
<?php
$dbh = new PDO('pgsql:host=localhost;dbname=[YOUR_DATABASE_NAME]');
?>
```

Seit OS X 10.9 hat die mitgelieferte PHP-Distribution keine PostgreSQL-Unterstützung mehr.
Die einfachste Methode um PHP mit PostgreSQL am Mac zu verwenden ist [MAMP](http://www.mamp.info/).