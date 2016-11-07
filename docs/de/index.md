---
layout: index
title: Postgres.app – der schnellste Weg zu PostgreSQL am Mac
---

<header>
	<img src="/img/PostgresAppIconLarge.png" width="192" height="192" alt="Postgres.app Icon" itemprop="image">
	<hgroup>
	  <h1 itemprop="name">Postgres.app</h1>
	  <h2 itemprop="description">Der schnellste Weg zu PostgreSQL am Mac</h2>
	</hgroup>
</header>

<div class="buttons">
	<a href="{{ site.downloadLocation }}" onclick="trackOutboundLink(this.href,'download');return false;" class="btn btn-primary btn-lg"><span class="glyphicon glyphicon-download-alt"></span> Laden</a>
	<a href="/de/documentation/" class="btn btn-default btn-lg"><span class="glyphicon glyphicon-book"></span> Dokumentation</a>
	<a href="https://github.com/postgresapp/postgresapp" onclick="trackOutboundLink(this.href);return false;" class="btn btn-default btn-lg"><span class="glyphicon glyphicon-cloud"></span> Github</a>
</div>

<div id="requirements">
	PostgresApp enthält PostgreSQL {{site.postgresqlVersion}} (andere Versionen siehe unten)<br>
	Postgres.app benötigt OS X 10.7 oder neuer.
</div>


Kurzanleitung
-------------
1. Herunterladen
2. In den Programme-Ordner bewegen
3. Doppelklicken

Fertig! Jetzt läuft ein PostgreSQL Server auf deinem Mac.
[Konfiguriere die `$PATH` Variable](documentation/cli-tools.html) damit du die mitgelieferten Kommandozeilenprogramme verwenden kannst.
Wenn du graphische Clients bevorzugst, gibt es eine [Liste von GUI Tools](documentation/gui-tools.html).

Was ist alles drin?
-------------------

Postgres.app enthält eine vollständige Installation die keine Wünsche offen lässt:

- [PostgreSQL](http://www.postgresql.org) {{site.postgresqlVersion}}
- [PostGIS](http://postgis.net) {{site.postgisVersion}}
- Unterstüzte Sprachen für Stored Procedures: [PL/pgSQL](http://www.postgresql.org/docs/current/static/plpgsql.html), [PL/Perl](http://www.postgresql.org/docs/current/static/plperl.html), [PL/Python](http://www.postgresql.org/docs/current/static/plpython.html), und [PLV8 (Javascript)](https://github.com/plv8/plv8)
- Beliebte Erweiterungen wie [hstore](http://www.postgresql.org/docs/current/static/hstore.html) und [uuid-ossp](http://www.postgresql.org/docs/current/static/uuid-ossp.html), und mehr!
- Viele [Tools für die Kommandozeile](/documentation/cli-tools.html), für PostgreSQL und GIS-Anwendungen

Andere Versionen
----------------

Suchst du eine bestimmte Version von PostgreSQL?

<a href="{{ site.downloadLocation93 }}" onclick="trackOutboundLink(this.href,'download');return false;" class="btn btn-default" style="margin-bottom: 10px;"><span class="glyphicon glyphicon-download-alt"></span> PostgreSQL {{site.postgresqlVersion93}}</a> mit PostGIS {{site.postgisVersion93}}

<a href="{{ site.downloadLocation94 }}" onclick="trackOutboundLink(this.href,'download');return false;" class="btn btn-default" style="margin-bottom: 10px;"><span class="glyphicon glyphicon-download-alt"></span> PostgreSQL {{site.postgresqlVersion94}}</a> mit PostGIS {{site.postgisVersion94}}

<a href="{{ site.downloadLocation95 }}" onclick="trackOutboundLink(this.href,'download');return false;" class="btn btn-default" style="margin-bottom: 10px;"><span class="glyphicon glyphicon-download-alt"></span> PostgreSQL {{site.postgresqlVersion95}}</a> mit PostGIS {{site.postgisVersion95}}

<a href="{{ site.downloadLocation96 }}" onclick="trackOutboundLink(this.href,'download');return false;" class="btn btn-default" style="margin-bottom: 10px;"><span class="glyphicon glyphicon-download-alt"></span> PostgreSQL {{site.postgresqlVersion96}}</a> mit PostGIS {{site.postgisVersion96}}

Du findest noch mehr Versionen auf der <a href="https://github.com/PostgresApp/PostgresApp/releases" onclick="trackOutboundLink(this.href);return false;">„Releases“-Seite</a> auf Github.

Support
-------

Hilfe bekommt man am schnellsten auf Twitter: [@PostgresApp](https://twitter.com/PostgresApp) versteht auch Deutsch!

Aufwändigere Fragen bitte auf Github stellen: [PostgresApp Issues](https://github.com/postgresapp/postgresapp/issues).

Ganz wichtig wenn du eine Frage stellst: Lass uns wissen welche Version von Postgres.app und OS X du verwendest.
Und sag uns ganz genau welche Fehlermeldung angezeigt wird!


Mitmachen
---------

Jede Hilfe ist willkommen! Hier sind ein paar Vorschläge wie du zum Projekt beitragen könntest:

- Hilf anderen Fehler zu beheben auf [Github Issues](https://github.com/postgresapp/postgresapp/issues)
- Beantworte Fragen auf [Stack Overflow](http://stackoverflow.com/questions/tagged/postgres.app)
- Teste [neue Versionen](https://github.com/PostgresApp/PostgresApp/releases) der App
- Korrigiere Fehler, mach Verbesserungen, und [sende einen Pull-Request](https://github.com/PostgresApp/PostgresApp/pulls)
- Verbessere die [Dokumentation](https://github.com/PostgresApp/postgresapp/tree/master/docs/documentation)
- Hilf mit bei der Übersetzung der Webseite

Wenn du mitmachen willst, kannst du auch jederzeit ein Email an Jakob Egger schreiben: <jakob@eggerapps.at>.

Lizenz
------

Postgres.app, PostgreSQL und die mitgelieferten Erweiterungen werden unter der [PostgreSQL Lizenz](http://www.postgresql.org/about/licence/) veröffentlicht.

PostGIS ist unter [GPLv2](http://opensource.org/licenses/gpl-2.0) lizensiert.

PLV8 verwendet eine [BSD Lizenz](http://opensource.org/licenses/BSD-3-Clause).


Impressum
------------

Postgres.app wird von derzeit von [Jakob Egger](https://github.com/jakob) und [Chris Pastl](https://github.com/chrispysoft) weiterentwickelt und betreut.

Postgres.app wurde ursprünglich von [Mattt Thompson](https://github.com/mattt) entwickelt.
