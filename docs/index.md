---
layout: index
title: Postgres.app – the easiest way to get started with PostgreSQL on the Mac
---

<header>
	<img src="/img/PostgresAppIconLarge.png" width="192" height="192" alt="Postgres.app Icon" itemprop="image">
	<hgroup>
	  <h1 itemprop="name">Postgres.app</h1>
	  <h2 itemprop="description">The easiest way to get started with PostgreSQL on the Mac</h2>
	</hgroup>
</header>

<div class="buttons">
	<a href="{{ site.downloadLocation }}" onclick="trackOutboundLink(this.href,'download');return false;" class="btn btn-primary btn-lg"><span class="glyphicon glyphicon-download-alt"></span> Download</a>
	<a href="https://postgresapp.com/documentation/" class="btn btn-default btn-lg"><span class="glyphicon glyphicon-book"></span> Documentation</a>
	<a href="https://github.com/postgresapp/postgresapp" onclick="trackOutboundLink(this.href);return false;" class="btn btn-default btn-lg"><span class="glyphicon glyphicon-cloud"></span> Github</a>
</div>

<div id="requirements">
	PostgresApp contains PostgreSQL {{site.postgresqlVersion}} (other versions see below)<br>
	Postgres.app runs on OS X 10.7 or later.
</div>


Quick Installation Guide
-----------------
1. Download
2. Move to `/Applications`
3. Double Click

Done! You now have a PostgreSQL server running on your Mac.
To use the command line programs, [set up your `$PATH`](documentation/cli-tools.html).
If you prefer a graphical app, check out the [list of GUI tools](documentation/gui-tools.html).

If you get an error saying “the identity of the developer cannot be confirmed”, please make sure you didn't skip step 2. (<a href="https://github.com/PostgresApp/PostgresApp/issues/272">more info</a>)

What's In The Box?
------------------

Postgres.app contains a full-featured PostgreSQL installation in a single package:

- [PostgreSQL](http://www.postgresql.org) {{site.postgresqlVersion}}
- [PostGIS](http://postgis.net) {{site.postgisVersion}}
- Procedural languages: [PL/pgSQL](http://www.postgresql.org/docs/current/static/plpgsql.html), [PL/Perl](http://www.postgresql.org/docs/current/static/plperl.html), [PL/Python](http://www.postgresql.org/docs/current/static/plpython.html), and [PLV8 (Javascript)](https://github.com/plv8/plv8)
- Popular extensions, including [hstore](http://www.postgresql.org/docs/current/static/hstore.html) and [uuid-ossp](http://www.postgresql.org/docs/current/static/uuid-ossp.html), and more
- A number of [command-line utilities](documentation/cli-tools.html) for managing PostgreSQL and working with GIS data

Other versions
--------------

Are you looking for a specific version of PostgreSQL? The following popular builds are available:

<a href="{{ site.downloadLocation93 }}" onclick="trackOutboundLink(this.href,'download');return false;" class="btn btn-default" style="margin-bottom: 10px;"><span class="glyphicon glyphicon-download-alt"></span> PostgreSQL {{site.postgresqlVersion93}}</a> with PostGIS {{site.postgisVersion93}}

<a href="{{ site.downloadLocation94 }}" onclick="trackOutboundLink(this.href,'download');return false;" class="btn btn-default" style="margin-bottom: 10px;"><span class="glyphicon glyphicon-download-alt"></span> PostgreSQL {{site.postgresqlVersion94}}</a> with PostGIS {{site.postgisVersion94}}

<a href="{{ site.downloadLocation95 }}" onclick="trackOutboundLink(this.href,'download');return false;" class="btn btn-default" style="margin-bottom: 10px;"><span class="glyphicon glyphicon-download-alt"></span> PostgreSQL {{site.postgresqlVersion95}}</a> with PostGIS {{site.postgisVersion95}}

<a href="{{ site.downloadLocation96 }}" onclick="trackOutboundLink(this.href,'download');return false;" class="btn btn-default" style="margin-bottom: 10px;"><span class="glyphicon glyphicon-download-alt"></span> PostgreSQL {{site.postgresqlVersion96}}</a> with PostGIS {{site.postgisVersion96}}

You can find even more versions on the <a href="https://github.com/PostgresApp/PostgresApp/releases" onclick="trackOutboundLink(this.href);return false;">Releases Page</a> on Github.

Support
-------

The quickest way to get help is to ask [@PostgresApp](https://twitter.com/PostgresApp) on Twitter, or to [open an issue](https://github.com/postgresapp/postgresapp/issues) on Github.

When reporting bugs, let us know which version of Postgres.app & OS X you are using, and be sure to include detailed error messages, even if your issue seems similar to another one.

Contribute
----------

Want to contribute to the project? Here are some great ways you can help:

- Troubleshoot [reported issues](https://github.com/postgresapp/postgresapp/issues)
- Answer [questions on Stack Overflow](http://stackoverflow.com/questions/tagged/postgres.app)
- Test [pre-release versions](https://github.com/PostgresApp/PostgresApp/releases) of the app
- Fork Postgres.app, fix a bug, and [send a pull request](https://github.com/PostgresApp/PostgresApp/pulls)
- Improve the [documentation](https://github.com/PostgresApp/postgresapp/tree/master/docs/documentation)

For more information on how you can contribute, email Jakob Egger: <jakob@eggerapps.at>.

License
-------

Postgres.app, PostgreSQL, and its extensions are released under the [PostgreSQL License](http://www.postgresql.org/about/licence/).

PostGIS is released under the [GNU General Public License (GPLv2)](http://opensource.org/licenses/gpl-2.0).

PLV8 is released under the [BSD 3-Clause License](http://opensource.org/licenses/BSD-3-Clause).

Credits
-------

Postgres.app is maintained by [Jakob Egger](https://github.com/jakob) and [Chris Pastl](https://github.com/chrispysoft).

Postgres.app was created by [Mattt Thompson](https://github.com/mattt).
