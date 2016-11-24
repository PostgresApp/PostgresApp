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
			<li><a href="documentation/">Documentation</a></li>
			<li>
				<a href="{{ site.github.repository_url }}">Github <span class="note">{{ site.github.public_repositories[0].stargazers_count }} stars</span></a>
			</li>
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

<table class="settings">
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
		<td class="light">your system user name</td>
	</tr>
	<tr>
		<td>Database</td>
		<td class="light">same as user</td>
	</tr>
	<tr>
		<td>Password</td>
		<td class="light">none</td>
	</tr>
	<tr>
		<td>Connection URL</td>
		<td>postgresql://localhost</td>
	</tr>
</table>

To connect with psql, double click a database. To connect directly from the command line, type `psql`. If you'd rather use a graphical client, see below.

NOTE: These instructions assume that you've never installed PostgreSQL on your Mac before.
If you have previously installed PostgreSQL using Postgres.app, homebrew, or the EnterpriseDB installer, please follow the [instructions for upgrading PostgreSQL](#) instead.


Graphical Clients
-----------------

Postgres.app includes `psql`, a versatile command line client for PostgreSQL.
But it's not the only option; there are plenty of great graphical clients available for PostgreSQL.
Two popular tools are:

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


How to connect
--------------

After your PostgreSQL server is up and running, you'll probably want to connect to it from your application.
Here's how to connect to PostgreSQL from popular programming languages and frameworks:

<dl class="connect-info">
	<dt class="active" onclick="this.parentElement.getElementsByClassName('active')[0].className='';this.className='active';">PHP</dt>
	<dd>
			<p>
				To connect from PHP, make sure that you have the PostgreSQL PDO driver.
				The version included with macOS doesn't support PostgreSQL.
				I recommend <a href="https://www.mamp.info">MAMP</a> for an easy way to install a current version of PHP that supports PostgreSQL.
			</p>
			<pre>&lt;?php
    $db = new PDO('pgsql:host=localhost;dbname=jakob');
    $statement = $db->prepare("SELECT * FROM people WHERE name ILIKE 'j%'");
    $statement->execute();
    while ($row = $statement->fetch()) {
        echo "&lt;p>" . htmlspecialchars($row["name"]) . "&lt;/p>"
    }
?></pre>
	</dd>
	
	<dt onclick="this.parentElement.getElementsByClassName('active')[0].className='';this.className='active';">Python</dt>
	<dd>
		<p>
			To connect to a PostgreSQL server with Python, please first install the psycopg2 library:
		</p>
		<pre>pip install psycopg2</pre>
		
		<p>To connect with SQLAlchemy:</p>
		<pre>from sqlalchemy import create_engine
engine = create_engine('postgresql://localhost/[YOUR_DATABASE_NAME]')</pre>
	</dd>
	
	<dt onclick="this.parentElement.getElementsByClassName('active')[0].className='';this.className='active';">Ruby on Rails</dt>
	<dd>
	</dd>
	
	<dt onclick="this.parentElement.getElementsByClassName('active')[0].className='';this.className='active';">Java</dt>
	<dd>
		<ol>
			<li>
				Download and install the <a href="https://jdbc.postgresql.org/download.html">PostgreSQL JDBC driver</a>
			</li>
			<li>
				Connect to the JDBC URL <tt>jdbc:postgresql://localhost/DATABASENAME</tt>
			</li>
		</ol>
	</dd>
	
	<dt onclick="this.parentElement.getElementsByClassName('active')[0].className='';this.className='active';">C</dt>
	<dd>
		<p>
			libpq is the native C client library for connecting to PostgreSQL.
		</p>
		<pre>PGconn *conn = PQconnectdb("postgresql://localhost/DATABASENAME");
</pre>
	</dd>
	
	<dt onclick="this.parentElement.getElementsByClassName('active')[0].className='';this.className='active';">Swift</dt>
	<dd>
		<p>
			You can use the C API in Swift.
		</p>
		<pre>let conn = PQconnectdb("postgresql://localhost/DATABASENAME")</pre>
	</dd>
</dl>



Support
-------

The quickest way to get help is to ask [@PostgresApp](https://twitter.com/PostgresApp) on Twitter, or to [open an issue](https://github.com/postgresapp/postgresapp/issues) on Github.

When reporting bugs, let us know which version of Postgres.app & OS X you are using, and be sure to include detailed error messages, even if your issue seems similar to another one.



License
-------

Postgres.app, PostgreSQL, and its extensions are released under the [PostgreSQL License](http://www.postgresql.org/about/licence/). 
The released binaries also include OpenSSL ([OpenSSL License](#)), PostGIS ([GPLv2](http://opensource.org/licenses/gpl-2.0)), and plv8 ([3 clause BSD](http://opensource.org/licenses/BSD-3-Clause)).

Postgres.app is maintained by [Jakob Egger](https://github.com/jakob) and [Chris Pastl](https://github.com/chrispysoft). It was originally created by [Mattt Thompson](https://github.com/mattt).