---
redirect_from:
  - /l/reindex_warning/
title: Reindexing your database 
---

"Databases should be reindexed" Warning
=======================================

This warning is displayed in case Postgres.app has reasons to believe the databases of 
that server may be affected of index corruption due to a change in the locales provided by
macOS.

The default text sort order has changed in macOS 11. This means that indexes on text-based
columns created before this change are no longer valid and they can cause data corruption.

TL;DR;
------
If you just installed your machine and created a fresh Postgres server, the message is
likely a false positive and you can click on "Hide This Warning". Otherwise we recommend
to reindex the cluster and then confirm the warning. In case reindexing not actually 
needed, it won't do any harm.

To reindex you database:
* Start the affected cluster (server)
* Open a terminal and run [`reindexdb -a <database>`](https://www.postgresql.org/docs/current/app-reindexdb.html)
  (or `reindexdb -a -p <port> <database>` if the server is running on a non-standard port).
  Repeat this for every <database> on the affected server.
  - If you get an error _'command not found'_, you don't have setup you path correctly. 
    Either [do so](cli-tools.html) or use an explicit path: 
    `/Applications/Postgres.app/Contents/Versions/latest/bin/reindexdb -a <database>`
  - If you get an error _'connection to server .. failed'_ you likely have an 
    authentication error. You need to supply the necessary connection paramaters of a 
    superuser, likely `-U postgres`. If you are prompted for an password, this was not set
    by PostgresApp.
  - If you see _'ERROR:  must be owner of database'_ supply the connection parameters to a 
    superuser or connect to the database as its owner via `psql` and run 
    `REINDEX DATABASE <databasename>;`
  - If you see errors like _`ERROR:  could not create unique index`_ take a note on the 
    message and the details below, connect to the database in question, and manually
    resolve the unique conflict. When querying the data, try to avoid using indexes, e.g.
    by issuing `SET enable_indexscan = off; SET enable_indexonlyscan = off; SET enable_bitmapscan = off;`
    in the session you use for this. Then retry the reindex operation.
* Confirm the warning message in PostgresApp by clicking on 'More Info' and choose 
  'Hide This Warning'.

Please note that to perform the reindex any concurrent writing transactions need to come
to an end and new transactions and sessions may need to wait for the reindex to finish. If
any client keeps a writing transaction open, the reindex operation will block and wait for 
that without any warning. You can cancel and restart the operation if needed.

If you need to perform this on a active system, you should do it during a maintenance
window. Reindexing a big database can take a significant amount of time. 


Backgrund
---------

If not explicitly requested otherwise (ICU collations), PostgreSQL uses the collations
(language dependent rules for sorting text) provided by the operation system. PostgresApp
sets the default locale (and thus collation) to 'en_US.UTF-8' when initialising a new
cluster since PostgresQL 9.4.1 (End of 2014). However, UTF-8 based collations are not
actually implemented in macOS (like in most BSD Systems). Thus, the effective sort order
was rather following byte order, see [Ticket #216](https://github.com/PostgresApp/PostgresApp/issues/216).

With the update to macOS 11, Apple started to use the ISO8859-1 collations for about half
of the available locales, including the default locale of Postgres.app, 'en_US.UTF-8'. As
Database Indexes store the order of elements at the time these are inserted, corruption
can happen if the sorting rules change later.


Is my database affected
-----------------------

Postgres.app records the version of macOS where `initdb` was called, and also all versions 
of macOS that the server was started on. Since this information is not available for old 
data directories, Postgres.app guesses the macOS version used to call `initdb` for 
existing data directories based on the install history of macOS updates. If Postgres.app 
detects that the data directory was used both pre macOS 11 and post macOS 11 or the macOS 
version used for initdb of a data directory is unknown, it shows the reindex warning. 

So the warning is a good indicator, but may not be absolutely accurate. If you prefer to 
do a manual assessment, here are some guidelines:

You are not affected if:
* The database cluster ('Server' in PostgresApp) was initialized on macOS 11 or later.
* You are still using macOS 10.15 or earlier.
* `initdb` was run manually (not with the button 'Initialize' within PostgresApp) with
  `--no-locale`, `--lc-collate` or `--locale` set to "C" or "POSIX" or to an unaffected
  locale and no other libc-based collations are used on columns or in indexes. Database 
  default collation can be shown with `SELECT datname, datcollate FROM pg_database;`,
  use of object level collations can be determined by joining `pg_depend` with 
  `pg_collation`.
* The database was restored from a logic dump (`pg_dump` / `pg_dumpall`) after updating 
  the OS version (exception: range partion keys, see below).

You are likely affected if:
* The the OS was updated from macOS 10.15 or earlier to macOS 11 or later 'in-place' with
  an existing PostgreSQL database.
* You used Migration Assistant or TimeMachine to copy the user data containing a 
  PostgreSQL data directory from a Mac using macOS 10.15 or earlier to macOS 11 or later.
* You used `pg_upgrade` on macOS 11 or later to update a cluster inited on macOS 10.15 or
  earlier.
* You copied over a data directory or a physical backup (`pg_basebackup`) from a Mac
  using macOS 10.15 or earlier to macOS 11 or later or vice versa.

There is no relation with the version of PostgresApp or PostgreSQL or with the 
architecture (Apple Silcon / Intel) in use.


Advanced Stuff
----------------

* You can monitor the reindex progress:
  - To see the finished objects, add `-v` to the `reindexdb` command line  or `(VERBOSE)`
    to `REINDEX DATABASE` command
  - To see progress during index creation in PostgreSQL 11 or newer have a look to the
    [`pg_stat_progress_create_index` view](https://www.postgresql.org/docs/current/progress-reporting.html#CREATE-INDEX-PROGRESS-REPORTING)
    in psql: `TABLE pg_stat_progress_create_index \watch 1`
  - To monitor if the process waits to get a lock, look for `wait_event` 'Lock' in the
    [`pg_stat_activity` view](https://www.postgresql.org/docs/current/monitoring-stats.html#MONITORING-PG-STAT-ACTIVITY-VIEW)
* To limit the time heavyweight locks are required, it is possible to run the reindex in
  batches, in parallel and concurrently. See documentation for the parameters.
* You can limit the reindex-operation to indexes that contain text based columns. To
  display these:
```sql
SELECT indrelid::regclass::text, indexrelid::regclass::text, collname, pg_get_indexdef(indexrelid) 
FROM (SELECT indexrelid, indrelid, indcollation[i] coll FROM pg_index, generate_subscripts(indcollation, 1) g(i)) s 
  JOIN pg_collation c ON coll=c.oid
WHERE collprovider IN ('d', 'c') AND collname NOT IN ('C', 'POSIX');
```
* You can further limit the reindex operation to the indexes that actually became invalid 
  with the help of the extension [`amcheck`](https://www.postgresql.org/docs/current/amcheck.html):
  `bt_index_check('<index_name>', is_unique);`
* If you use clustered tables, you should recluster them after reindexing:
  [`clusterdb -a`](https://www.postgresql.org/docs/current/app-clusterdb.html) or
  [`CLUSTER <table_name>;`](https://www.postgresql.org/docs/current/sql-cluster.html). 
* In case you use partitioned tables with Range Partitioning on a text based column, it
  is possible, a repartitioning is needed. One way to do this (PostgreSQL 12 onwards) uses 
  `pg_dump` with the `--load-via-partition-root` option.
* In case you use `CHECK` constraints that depend on character order it is possible you
  have undetected constraint violations in the existing data.
  Unlike the `UNIQUE` violations mentioned before, these need to be searched for and 
  resolved manually.
* If you previously created indexes on text-based columns for use with pattern matching 
  queries (`LIKE`, `~` operators), you may want to create additional indexes with the 
  matching [`xxx_pattern_ops` opclass](https://www.postgresql.org/docs/current/indexes-opclass.html)
  to restore support for this.
* When using streaming replication, the collations of the standby need to match these on
  the primary, otherwise corrupting the standby is likely just like if one of the 
  machines's OS is updated across the macOS 10.15 / macOS 11 boundary.

  
Further reading
---------------

* [PostgresSQL Wiki on collation changes](https://wiki.postgresql.org/wiki/Locale_data_changes)
* [Docs on `REINDEX` command](https://www.postgresql.org/docs/current/sql-reindex.html)
* [PostgresApp Ticket #216](https://github.com/PostgresApp/PostgresApp/issues/216)
* [PostgresApp Ticket #665](https://github.com/PostgresApp/PostgresApp/issues/665)

