---
layout: documentation
title: Postgres.app Extensions
---

## Bundled Extensions

<p>Postgres.app comes with a lot of popular extensions. All you need to do is enable them with the <a href="https://www.postgresql.org/docs/current/sql-createextension.html">CREATE EXTENSION</a> command and you are good to go!</p>

<style>
  .extension {
  	background: #5E94BD;
  	border-radius: 6px;
  	padding: 20px;
  	margin: 0 0 25px;
  	position: relative;
  	color: #fff;
  }

  .extension-hint {
  	color: rgba(255,255,255,0.65);
  	font-size: 13px;
    margin: 1em 0 0;
  }
  .extension-description {
  	color: rgba(255,255,255,0.9);
  	font-size: 13px;
    margin: 1em 0;
  }
  .extension a {
    color: #fff;
  }
  .extension h1 {
  	color: #D6FFF8;
  	color: rgba(255,255,255,0.8);
  	color: #fff;
  	margin: 0 0 10px;
  	font-size: 24px;
  	font-family: -apple-system, ".SFNSText-Regular", "San Francisco", "Roboto", "Segoe UI", "Helvetica Neue", "Lucida Grande", sans-serif;
  	font-weight: 400;
  }

  .extension .download {
  	background: #AEE4DB;
  	background: #fff;
  	background: rgba(255,255,255,0.8);
  	padding: 6px 8px;
  	color: rgba(20,44,147,0.84);
  	color: #000;
  	text-decoration: none;
  	font-size: 18px;
  	border-radius: 6px;
  	position: absolute;
  	right: 20px;
  	bottom: 20px;
  }
</style>

<div class="extension">
	<h1>PostGIS</h1>
	<div class="extension-description">
      PostGIS is a popular geospatial extension for PostgreSQL.
	  It includes the GDAL, PROJ.4 and GEOS libraries and comes with everything you need to work with geographic vector and raster data.
      Learn everything about this extension at <a href="https://postgis.net">postgis.net</a>
	</div>
	<div class="extension-hint">
			✓ this extension is included with Postgres.app
	</div>
</div>

<div class="extension">
	<h1>pgRouting</h1>
	<div class="extension-description">
      Extends PostGIS to provide geospatial routing functionality. Project homepage: <a href="https://pgrouting.org">pgrouting.org</a>
	</div>
	<div class="extension-hint">
			✓ this extension is included with Postgres.app
	</div>
</div>

<div class="extension">
	<h1>pgvector</h1>
	<div class="extension-description">
      Open-source vector similarity search for Postgres. Learn how to store vectors with the rest of your data at <a href="https://github.com/pgvector/pgvector">github.com/pgvector/pgvector</a>
	</div>
	<div class="extension-hint">
			✓ this extension is included with Postgres.app
	</div>
</div>

<div class="extension">
	<h1>PL/Python</h1>
	<div class="extension-description">
      Write stored procedures and functions in Python!
  </div>
	<div class="extension-hint">
			This extension is included with Postgres.app, but you need to install Python from <a href="https://www.python.org/downloads/">python.org</a>. See our <a href="/documentation/plpython.html">Python instructions</a> for details.
	</div>
</div>

<div class="extension">
	<h1>PL/JS</h1>
	<div class="extension-description">
      Write stored procedures and functions in Javascript! This light-weight extension is based on the QuickJS runtime.
      Created by the PL/v8 author, instructions are available at <a href="https://github.com/plv8/pljs">github.com/plv8/pljs</a>
  </div>
	<div class="extension-hint">
			✓ this extension is included with Postgres.app
	</div>
</div>

<div class="extension">
	<h1>PL Debugger</h1>
	<div class="extension-description">
      Debug PL/PGSQL functions with pgAdmin. For instructions see the <a href="https://github.com/EnterpriseDB/pldebugger">Github repo</a> and the <a href="https://www.pgadmin.org/docs/pgadmin4/latest/debugger.html">pgAdmin documentation</a>
  </div>
	<div class="extension-hint">
			✓ this extension is included with Postgres.app
	</div>
</div>

<div class="extension">
	<h1>wal2json</h1>
	<div class="extension-description">
	  wal2json is an output plugin for logical decoding. Track changes to the database as they happens!
      For details, see the <a href="https://github.com/eulerto/wal2json">Github repo</a>
  </div>
	<div class="extension-hint">
			✓ this extension is included with Postgres.app
	</div>
</div>


<p>
  Aside from these extensions, Postgres.app also includes most of the standard extensions such as plpgsql, pg_crypto, and so on.
  We do not include PL/TCL and PL/Perl because macOS no longer supports linking to these languages.
  For a full list of included extensions, see the catalog table <tt>pg_available_extensions</tt>.
</p>

## Downloadable Extensions for PostgreSQL 18

<p>
  We are also offering some popular extensions as an additional download.
  They are very easy to install -- just download and double click the installer package!
  After restarting the server, you can enable them with the <tt>CREATE EXTENSION</tt> command.
</p>

<div class="extension">
	<h1>PL/v8</h1>
	<div class="extension-description">
      Run stored procedures and functions in Javascript -- FAST.
      This extension is based on Chrome's v8 JavaScript runtime. It is probably the fastest and most secure way to run JavaScript code in your database.
      Learn more about this extension at <a href="https://plv8.github.io">plv8.github.io</a>
  </div>
  <ul>
    <li>plv8 3.2.3</li>
    <li>built for PostgreSQL 18</li>
  </ul>
	<a class="download" href="https://github.com/PostgresApp/PostgresApp/releases/download/v2.8.3/plv8-pg18-3.2.3.pkg">⤓ Download for Postgres.app</a>
</div>

<div class="extension">
	<h1>http</h1>
	<div class="extension-description">
      Did you ever want to call a webhook from a database trigger?
      This extension allows you to access web services and connect to REST APIs directly from PostgreSQL.
      Find out more at <a href="https://github.com/pramsey/pgsql-http">github.com/pramsey/pgsql-http</a>
  </div>
  <ul>
    <li>pg http 1.6.3</li>
    <li>built for PostgreSQL 18</li>
  </ul>
	<a class="download" href="https://github.com/PostgresApp/Extensions/releases/download/http-1.6.3/http-pg18-1.6.3.pkg">⤓ Download for Postgres.app</a>
</div>

<div class="extension">
	<h1>pg_parquet</h1>
	<div class="extension-description">
      <a href="https://parquet.apache.org/">Apache Parquet</a> is gaining popularity as an interchange format for datasets.
      This extension allows you to read and write Parquet files using the COPY command.
      The extension was developed by CrunchyData and documentation is available at <a href="https://github.com/CrunchyData/pg_parquet">github.com/CrunchyData/pg_parquet</a>
  </div>
  <ul>
    <li>pg_parquet 0.4.0</li>
    <li>built for PostgreSQL 18</li>
  </ul>
	<a class="download" href="https://github.com/PostgresApp/Extensions/releases/download/pg_parquet-0.4.0-18beta2/pg_parquet-pg18-0.4.0.pkg">⤓ Download for Postgres.app</a>
</div>

<p>
  Is your favorite extension still missing? Open an issue in our Github repo and request it!
</p>

## Building extensions from source

<p>There are hundreds of PostgreSQL extensions and we can't build them all. If you want to use an extension that is not available for download, you can build it yourself.

<p>
If you are using PostgreSQL 18 or later, make sure to install extensions into the "Application Support" directory.
This ensures that extensions will continue to work after installing Postgres.app updates.

<p>
Postgres.app automatically configures the necessary search paths for every extension installed in a subdirectory of <code class="language-plaintext highlighter-rouge">~/Library/Application Support/Postgres/Extensions/XX</code> (XX is the major PostgreSQL version).</p>

<p>Before building an extension, make sure that your $PATH is configured correctly:</p>

<pre>
  pg_config --version
</pre>

<p>This command should print <tt>PostgreSQL XX.X (Postgres.app)</tt>.
Make sure the version matches what you expect!

<p>The next step is to build your extension. <strong>You need to have a compiler installed!</strong>
 You can either use Xcode or the Command Line Tools.
  
<p>Compile the code with commands similar to these:

<pre>
  git clone git@github.com:theory/pg-envvar.git
  cd pg-envvar
  make
</pre>

If everything worked, you can install your extension into application support with this command:

<pre>
  make install prefix="$HOME/Library/Application Support/Postgres/Extensions/XX/local"
</pre>

<em>
  Note: If you are using <strong>PostgreSQL 17 or earlier</strong>, this will not work.
  PostgreSQL versions before 18 require extensions to be installed in the PostgreSQL installation directory.
  To install them there, remove the prefix argument from the make install command. If you run into an "Operation not permitted" error, make sure that you grant Terminal permission to update applications in System settings.
  Please note that you will have to re-install the extension after every Postgres.app update.
</em>
