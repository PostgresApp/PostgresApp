---
layout: documentation
title: Configuring PHP for Postgres.app
---

### PHP

#### [PDO](http://www.php.net/manual/en/book.pdo.php)

Make sure your PHP setup has PDO installed (it is enabled by default in PHP 5.1.0 or above), and the [PostgreSQL PDO driver](http://www.php.net/manual/en/ref.pdo-pgsql.php) is enabled. Then a database connection can be established with:

``` php
<?php
$dbh = new PDO('pgsql:host=localhost;dbname=[YOUR_DATABASE_NAME]');
?>
```

The default PHP that comes with OS X 10.9 does not have Postgres support.
The easiest way to use PHP with Postgres is to use [MAMP](http://www.mamp.info/).