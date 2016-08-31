---
layout: documentation
title: Configuring Java for Postgres.app
---

### Java

#### [JDBC](http://www.oracle.com/technetwork/java/javase/jdbc/index.html)


``` java
PGSimpleDataSource dataSource = new PGSimpleDataSource();
dataSource.setDatabaseName(YOUR_DATABASE_NAME);
```

The easiest way to get the [PostgreSQL JDBC driver](https://jdbc.postgresql.org/download.html) is using [Maven](https://maven.apache.org).

``` xml
<dependency>
  <groupId>org.postgresql</groupId>
  <artifactId>postgresql</artifactId>
  <version>9.4.1207</version>
</dependency>
```

Make sure the JDBC version of the driver matches your Java version.

<table border=1 cellpadding=4>
	<tr><th>Java Version</th><th>JDBC Version</th></tr>
	<tr><td>Java 1.6</td><td>JDBC 4.0</td></tr>
	<tr><td>Java 1.7</td><td>JDBC 4.1</td></tr>
	<tr><td>Java 1.8</td><td>JDBC 4.2</td></tr>
</table>

For more information check out the [Connecting to the Database](https://jdbc.postgresql.org/documentation/head/connect.html) chapter of the official documentation.

