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


Postgres.app includes PostgreSQL and popular extensions like [PostGIS](http://postgis.net) for geo data and [plv8](https://github.com/plv8/plv8) for Javascript - all inside a standard Mac app, no Installer required.

Postgres.app has a beautiful user interface and a convenient menu bar item.
You never need to touch the command line to use it – but of course we do include all the necessary [command-line tools](documentation/cli-tools.html) and header files for advanced users.

Postgres.app [updates automatically](foo), so you get bugfixes as fast as possible.

The new Postgres.app requires macOS 10.10 or later and comes with PostgreSQL versions 9.5 and 9.6, but we also maintain [older versions](foo) of Postgres.app.


<ul class="installInstructions">
	<li>Download -> Move to Applications folder -> Double Click<p>If you don't move Postgres.app to the Applications folder, you will see a warning about an unidentified developer and won't be able to open it.</p></li>
	<li>Click "Initialize" to create a new server</li>
	<li>Optional: Configure you $PATH to use the included command line tools:</li>
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

To connect with psql, just double click a database. To connect from the command line, just type 'psql'. If you'd rather use a graphical client, see below.

NOTE: These instructions assume that you've never installed PostgreSQL on your Mac before. If you have previously installed PostgreSQL using either Postgres.app, homebrew, the EnterpriseDB installers, or any other source, please follow the instructions for upgrading PostgreSQL instead.


Graphical Clients
-----------------

<ul class="clientApps">
	<li id="pgadmin"><a href="#">pgAdmin</a></li>
	<li id="postico"><a href="#">Postico</a></li>
</ul>

pgAdmin 4 is a feature rich open source PostgreSQL client. It has support for almost every feature in PostgreSQL. The only downside is that the cross-plattform UI really doesn't live up to the expectations of a native Mac app.

Postico on the other hand, is a very modern Mac app. It's mode by the same people that maintain Postgres.app (and we think you'll like it!). We put a lot of effort into making it easy to use! However, it doesn't have the extensive feature set of pgAdmin, and it's a commercial app rather than open source.

Aside from those two options, there are a lot more to choose from! Check the documentation for a list of amazing Mac apps for PostgreSQL.





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
