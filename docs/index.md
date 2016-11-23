---
layout: index
title: Postgres.app – the easiest way to get started with PostgreSQL on the Mac
---

<header>
	<hgroup>
	  	<h1 itemprop="name">Postgres.app</h1>
	  	<h2 itemprop="description">The easiest way to get started with PostgreSQL on the Mac</h2>
		<ul class="buttons">
			<li><a href="{{ site.downloadLocation }}">Download</a></li>
			<li><a href="https://postgresapp.com/documentation/">Documentation</a></li>
			<li><a href="https://github.com/postgresapp/postgresapp">Github</a></li>
		</ul>
	</hgroup>
</header>


Postgres.app is a full-featured PostgreSQL installation packaged as a standard Mac app.
It includes everything you need to get started:
we've even included popular extensions like [PostGIS](http://postgis.net) for geo data and [plv8](https://github.com/plv8/plv8) for Javascript.


Postgres.app has a beautiful user interface and a convenient menu bar item.
You never need to touch the command line to use it – but of course we do include all the necessary [command line tools](documentation/cli-tools.html) and header files for advanced users.



Postgres.app [updates automatically](foo), so you get bugfixes as soon as possible.

The current version requires macOS 10.10 or later and comes with PostgreSQL versions 9.5 and 9.6, but we also maintain [older versions](foo) of Postgres.app.



Installing Postgres.app
-----------------------

<ul class="instructions">
	<li>
		<p>Download &nbsp; ➜ &nbsp; Move to Applications folder &nbsp; ➜ &nbsp; Double Click</p>
		<p class="subdued">If you don't move Postgres.app to the Applications folder, you will see a warning about an unidentified developer and won't be able to open it.</p>
	</li>
	<li>
		<p>Click "Initialize" to create a new server</p>
	</li>
	<li>
		<p>Configure your <tt>$PATH</tt> to use the included command line tools (optional):</p>
		<pre>echo /Applications/Postgres.app/Contents/Versions/latest/bin | sudo tee /etc/paths.d/postgresapp</pre>
	</li>
</ul>

Done! You now have a PostgreSQL server running on your Mac with these default settings:

<table class="settingsTable">
	<tr>
		<td>Host</td>
		<td>localhost</td>
	</tr>
	<tr>
		<td>Port</td>
		<td>5432</td>
	</tr>
	<tr>
		<td>User</td>
		<td>(your system user name)</td>
	</tr>
	<tr>
		<td>Database</td>
		<td>(same as user)</td>
	</tr>
	<tr>
		<td>Password</td>
		<td>(none)</td>
	</tr>
	<tr>
		<td>URL</td>
		<td>postgres://localhost</td>
	</tr>
</table>

To connect with psql, double click a database. To connect directly from the command line, type <tt>psql</tt>. If you'd rather use a graphical client, see below.

NOTE: These instructions assume that you've never installed PostgreSQL on your Mac before.
If you have previously installed PostgreSQL using Postgres.app, homebrew, or the EnterpriseDB installer, please follow the [instructions for upgrading PostgreSQL](#) instead.


Graphical Clients
-----------------

<ul class="clients">
	<li id="pgadmin"><a href="https://www.pgadmin.org">pgAdmin 4</a></li>
	<li id="postico"><a href="https://eggerapps.at/postico/">Postico</a></li>
</ul>

[pgAdmin 4](https://www.pgadmin.org) is a feature rich open source PostgreSQL client.
It has support for almost every feature in PostgreSQL.
The only downside is that the cross-plattform UI really doesn't live up to the expectations of a native Mac app.

[Postico](https://eggerapps.at/postico/) on the other hand, is a very modern Mac app.
It's made by the same people that maintain Postgres.app, and we think you'll like it! 
We put a lot of effort into making it a joy to use.
However, it doesn't have the extensive feature set of pgAdmin, and it's a commercial app rather than open source.

Aside from those two options, there are a lot more to choose from! Check the documentation for a [list of amazing Mac apps for PostgreSQL](#).




Support
-------

The quickest way to get help is to ask [@PostgresApp](https://twitter.com/PostgresApp) on Twitter, or to [open an issue](https://github.com/postgresapp/postgresapp/issues) on Github.

When reporting bugs, let us know which version of Postgres.app & OS X you are using, and be sure to include detailed error messages, even if your issue seems similar to another one.



License
-------

Postgres.app, PostgreSQL, and its extensions are released under the [PostgreSQL License](http://www.postgresql.org/about/licence/). 
The released binaries also include OpenSSL ([OpenSSL License](#)), PostGIS ([GPLv2](http://opensource.org/licenses/gpl-2.0)), and plv8 ([3 clause BSD](http://opensource.org/licenses/BSD-3-Clause)).

Postgres.app is maintained by [Jakob Egger](https://github.com/jakob) and [Chris Pastl](https://github.com/chrispysoft). It was originally created by [Mattt Thompson](https://github.com/mattt).
