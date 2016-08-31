---
layout: documentation
title: Postgres.app mit Java verwenden
---

### Java

#### [JDBC](http://www.oracle.com/technetwork/java/javase/jdbc/index.html)


``` java
PGSimpleDataSource dataSource = new PGSimpleDataSource();
dataSource.setDatabaseName(YOUR_DATABASE_NAME);
```

Du kannst den [PostgreSQL JDBC driver](https://jdbc.postgresql.org/download.html) mit [Maven](https://maven.apache.org) installieren:

``` xml
<dependency>
  <groupId>org.postgresql</groupId>
  <artifactId>postgresql</artifactId>
  <version>9.4.1207</version>
</dependency>
```

Stelle sicher dass die JDBC-Version zu deiner Java-Version passt:

<table border=1 cellpadding=4>
	<tr><th>Java Version</th><th>JDBC Version</th></tr>
	<tr><td>Java 1.6</td><td>JDBC 4.0</td></tr>
	<tr><td>Java 1.7</td><td>JDBC 4.1</td></tr>
	<tr><td>Java 1.8</td><td>JDBC 4.2</td></tr>
</table>

Mehr info gibt es im Kapitel [Connecting to the Database](https://jdbc.postgresql.org/documentation/head/connect.html) in der offiziellen Dokumentation (auf Englisch).

