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

| Java Version | JDBC Version |
| ------------ | ------------ |
| Java 1.6     | JDBC 4.0     |
| Java 1.7     | JDBC 4.1     |
| Java 1.8     | JDBC 4.2     |

Mehr info gibt es im Kapitel [Connecting to the Database](https://jdbc.postgresql.org/documentation/head/connect.html) in der offiziellen Dokumentation (auf Englisch).

