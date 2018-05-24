---
layout: index
title: Postgres.app – the easiest way to get started with PostgreSQL on the Mac
---

Postgres.app is a full-featured PostgreSQL installation packaged as a standard Mac app.
It includes everything you need to get started:
we've even included popular extensions like [PostGIS](http://postgis.net) for geo data and [plv8](https://github.com/plv8/plv8) for JavaScript.


Postgres.app has a beautiful user interface and a convenient menu bar item.
You never need to touch the command line to use it – but of course we do include all the necessary [command line tools](/documentation/cli-tools.html) and header files for advanced users.



Postgres.app updates automatically, so you get bugfixes as soon as possible.

The current version requires macOS {{site.postgresappMinSystemVersion}} or later and comes with the latest PostgreSQL versions ({{ site.postgresqlVersions | map: "postgres" | array_to_sentence_string: "and" }}), but we also maintain [other versions](documentation/all-versions.html) of Postgres.app.

<div class="beta-banner">
	PostgreSQL 11 Beta 1 is available! <a href="https://github.com/PostgresApp/PostgresApp/releases/tag/v2.2beta1">More Details</a>
</div>

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
		<pre><code>sudo mkdir -p /etc/paths.d &&<br/>echo /Applications/Postgres.app/Contents/Versions/latest/bin | sudo tee /etc/paths.d/postgresapp</code></pre>
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
If you have previously installed PostgreSQL using homebrew, MacPorts, the EnterpriseDB installer, consider [removing other PostgreSQL installations](documentation/remove.html) first.
We also have [instructions for upgrading from older versions of Postgres.app](documentation/update.html).


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

Aside from those two options, there are a lot more to choose from! Check the documentation for a [list of amazing Mac apps for PostgreSQL](/documentation/gui-tools.html).


How to connect
--------------

After your PostgreSQL server is up and running, you'll probably want to connect to it from your application.
Here's how to connect to PostgreSQL from popular programming languages and frameworks:

<dl class="connect-info">
	<dt class="active" onclick="this.parentElement.getElementsByClassName('active')[0].className='';this.className='active';">PHP</dt>
	<dd>
			<p>
				To connect from PHP, make sure that it supports PostgreSQL.
				The version included with macOS doesn't support PostgreSQL.
				We recommend <a href="https://www.mamp.info">MAMP</a> for an easy way to install a current version of PHP that works.
			</p>
			<p>
				You can use PDO (object oriented):
			</p>
			<pre><code>&lt;?php
$db = new PDO('pgsql:host=localhost');
$statement = $db->prepare("SELECT datname FROM pg_database");
$statement->execute();
while ($row = $statement->fetch()) {
    echo "&lt;p>" . htmlspecialchars($row["datname"]) . "&lt;/p>\n";
}
?></code></pre>
			<p>
				Or the <tt>pg_connect()</tt> functions (procedural):
			</p>
			<pre><code>&lt;?php
$conn = pg_connect("postgresql://localhost");
$result = pg_query($conn, "SELECT datname FROM pg_database");
while ($row = pg_fetch_row($result)) {
    echo "&lt;p>" . htmlspecialchars($row[0]) . "&lt;/p>\n";
}
?></code></pre>
	</dd>
	
	<dt onclick="this.parentElement.getElementsByClassName('active')[0].className='';this.className='active';">Python</dt>
	<dd>
		<p>
			To connect to a PostgreSQL server with Python, please first install the psycopg2 library:
		</p>
		<pre><code>
pip install psycopg2
		</code></pre>
		<h3>Django</h3>
		<p>In your settings.py, add an entry to your DATABASES setting:</p>
		<pre><code>
DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.postgresql_psycopg2",
        "NAME": "[YOUR_DATABASE_NAME]",
        "USER": "[YOUR_USER_NAME]",
        "PASSWORD": "",
        "HOST": "localhost",
        "PORT": "",
    }
}
		</code></pre>
		<h3>Flask</h3>
		<p>When using the <a href="https://packages.python.org/Flask-SQLAlchemy/">Flask-SQLAlchemy</a> extension you can add to your application code:</p>
		<pre><code>
from flask import Flask
from flask.ext.sqlalchemy import SQLAlchemy
app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql://localhost/[YOUR_DATABASE_NAME]'
db = SQLAlchemy(app)
		</code></pre>
		<h3>SQLAlchemy</h3>
		<pre><code>
from sqlalchemy import create_engine
engine = create_engine('postgresql://localhost/[YOUR_DATABASE_NAME]')
		</code></pre>
	</dd>
	
	<dt onclick="this.parentElement.getElementsByClassName('active')[0].className='';this.className='active';">Ruby</dt>
	<dd>
		<p>To install the pg gem, make sure you have set up your <tt>$PATH</tt> correctly (see <a href="documentation/cli-tools.html">Command-Line Tools</a>), then execute the following command:</p>
		<pre><code>sudo ARCHFLAGS="-arch x86_64" gem install pg</code></pre>
		
		<h3>Rails</h3>
		<p>In config/database.yml, use the following settings:</p>
		<pre><code>
development:
    adapter: postgresql
    database: [YOUR_DATABASE_NAME]
    host: localhost
		</code></pre>
		<h3>Sinatra</h3>
		<p>In config.ru or your application code:</p>
		<pre><code>
set :database, "postgres://localhost/[YOUR_DATABASE_NAME]"
		</code></pre>
		<h3>ActiveRecord</h3>
		<p>Install the activerecord gem and require 'active_record', and establish a database connection:</p>
		<pre><code>
ActiveRecord::Base.establish_connection("postgres://localhost/[YOUR_DATABASE_NAME]")
		</code></pre>
		<h3>DataMapper</h3>
		<p>Install and require the datamapper and do_postgres gems, and create a database connection:</p>
		<pre><code>
DataMapper.setup(:default, "postgres://localhost/[YOUR_DATABASE_NAME]")
		</code></pre>
		<h3>Sequel</h3>
		<p>Install and require the sequel gem, and create a database connection:</p>
		<pre><code>
DB = Sequel.connect("postgres://localhost/[YOUR_DATABASE_NAME]")
		</code></pre>
	</dd>
	
	<dt onclick="this.parentElement.getElementsByClassName('active')[0].className='';this.className='active';">Java</dt>
	<dd>
		<ol>
			<li>
				Download and install the <a href="https://jdbc.postgresql.org/download.html">PostgreSQL JDBC driver</a>
			</li>
			<li>
				Connect to the JDBC URL <tt>jdbc:postgresql://localhost</tt>
			</li>
		</ol>
		<p>For more information see the official <a href="https://jdbc.postgresql.org/documentation/head/index.html">PostgreSQL JDBC documentation</a>.</p>
	</dd>
	
	<dt onclick="this.parentElement.getElementsByClassName('active')[0].className='';this.className='active';">C</dt>
	<dd>
		<p>
			libpq is the native C client library for connecting to PostgreSQL. It's really easy to use:
		</p>
		<pre><code>#include &lt;libpq-fe.h>
int main() {
    PGconn *conn = PQconnectdb("postgresql://localhost");
    if (PQstatus(conn) == CONNECTION_OK) {
        PGresult *result = PQexec(conn, "SELECT datname FROM pg_database");
        for (int i = 0; i &lt; PQntuples(result); i++) {
            char *value = PQgetvalue(result, i, 0);
            if (value) printf("%s\n", value);
        }
        PQclear(result);
    }
    PQfinish(conn);
}</code></pre>
		<p>Now compile the file with clang and run it:</p>
		<pre><code>clang main.c -I$(pg_config --includedir) -L$(pg_config --libdir) -lpq
./a.out</code></pre>
	</dd>
	
	<dt onclick="this.parentElement.getElementsByClassName('active')[0].className='';this.className='active';">Swift</dt>
	<dd>
		<p>
			You can just use the C API in Swift! First include libpq in your bridging header:
		</p>
		<pre><code>#import &lt;libpq-fe.h></code></pre>
		<p>
			Then make sure to link with libpq.
		</p>
		<p>
			On iOS, you'll need to build libpq yourself.
		</p>
		<p>
			On macOS you can use the system provided libpq (does not support SSL) or use libpq provided by Postgres.app
			by adding the following build settings:
		</p>
		<table>
			<tr>
				<th>Other Linker Flags</th>
				<td><tt>-lpq</tt></td>
			</tr>
			<tr>
				<th>Header Search Paths</th>
				<td><tt>/Applications/Postgres.app/Contents/Versions/latest/include</tt></td>
			</tr>
			<tr>
				<th>Library Search Paths</th>
				<td><tt>/Applications/Postgres.app/Contents/Versions/latest/lib</tt></td>
			</tr>
		</table>
		<p>
			Now you can use the <a href="https://www.postgresql.org/docs/current/static/libpq.html">libpq C library</a> to connect to PostgreSQL:
		</p>
		<pre><code>let conn = PQconnectdb("postgresql://localhost".cString(using: .utf8))
if PQstatus(conn) == CONNECTION_OK {
    let result = PQexec(conn, "SELECT datname FROM pg_database WHERE datallowconn")
    for i in 0 ..&lt; PQntuples(result) {
        guard let value = PQgetvalue(result, i, 0) else { continue }
        let dbname = String(cString: value)
        print(dbname)
    }
    PQclear(result)
}
PQfinish(conn)</code></pre>
	</dd>
</dl>



Support
-------

We have a list of common problems in the [troubleshooting section](/documentation/troubleshooting.html) in the documentation.

For general questions concerning PostgreSQL, have a look at the [official PostgreSQL documentation](https://www.postgresql.org/docs/current/static/).

If you have a question concerning Postgres.app that is not answered by the [Postgres.app documentation](/documentation/),
you can ask [@PostgresApp](https://twitter.com/PostgresApp) on Twitter, 
or [open an issue](https://github.com/postgresapp/postgresapp/issues) on GitHub.

When reporting bugs, let us know which version of Postgres.app & macOS you are using, and be sure to include detailed error messages, even if your issue seems similar to another one.



License
-------

Postgres.app, PostgreSQL, and its extensions are released under the [PostgreSQL License](http://www.postgresql.org/about/licence/). 
The released binaries also include OpenSSL ([OpenSSL License](https://www.openssl.org/source/license.html)), PostGIS ([GPLv2](http://opensource.org/licenses/gpl-2.0)), and plv8 ([3 clause BSD](http://opensource.org/licenses/BSD-3-Clause)).

Postgres.app is maintained by [Jakob Egger](https://github.com/jakob) and [Chris Pastl](https://github.com/chrispysoft). It was originally created by [Mattt Thompson](https://github.com/mattt).
