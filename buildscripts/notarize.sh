#!/bin/bash

set -e
set -o pipefail

export NSUnbufferedIO=YES
export PYTHONUNBUFFERED=1

trap 'if [[ $? -ne 0 ]]; then echo "Error"; echo "Check Log For Details"; fi' EXIT

# Call this script like this:
# POSTGRESAPP_SHORT_VERSION=2.x.x POSTGRESAPP_BUILD_VERSION=xx PG_BINARIES_VERSIONS=10_11_12 PG_BINARIES_DIR=~/Documents/postgresapp/binaries LATEST_STABLE_PG_VERSION=12 NOTARIZATION_USER=someone@example.com NOTARIZATION_PASSWORD=@keychain:apple-id SPARKLE_SIGNING_KEY=example.pem ./build.sh

if [ x$POSTGRESAPP_SHORT_VERSION = x ]
then
	echo "Please set the environment variable POSTGRESAPP_SHORT_VERSION"
	exit 1
fi

if [ x$POSTGRESAPP_BUILD_VERSION = x ]
then
	echo "Please set the environment variable POSTGRESAPP_BUILD_VERSION"
	exit 1
fi

if [ x$PG_BINARIES_VERSIONS = x ]
then
	echo "Please set the environment variable PG_BINARIES_VERSIONS"
	exit 1
fi

if [ x$PG_BINARIES_DIR = x ]
then
	echo "Please set the environment variable PG_BINARIES_DIR"
	exit 1
fi

if [ x$LATEST_STABLE_PG_VERSION = x ]
then
	echo "Please set the environment variable LATEST_STABLE_PG_VERSION"
	exit 1
fi

if [ x$NOTARIZATION_USER = x ]
then
	echo "Please set the environment variable NOTARIZATION_USER"
	exit 1
fi

if [ x$NOTARIZATION_PASSWORD = x ]
then
	echo "Please set the environment variable NOTARIZATION_PASSWORD, eg NOTARIZATION_PASSWORD=@keychain:service-name"
	exit 1
fi

if [ x$SPARKLE_SIGNING_KEY = x ]
then
	echo "Please set SPARKLE_SIGNING_KEY to the path of the DSA key used for signing sparkle updates."
	exit 1
fi


PROJECT_ROOT=$(dirname $(pwd))
PROJECT_FILE="$PROJECT_ROOT"/Postgres.xcodeproj

BUILD_DIR="$(dirname $(dirname $(pwd)))/archives/Postgres-$POSTGRESAPP_BUILD_VERSION-v$POSTGRESAPP_SHORT_VERSION-${PG_BINARIES_VERSIONS//_/-}"
LOG_DIR="$BUILD_DIR/notarize-log"
ARCHIVE_PATH="$BUILD_DIR"/Postgres.xcarchive
BGIMG_PATH=background-image/folder_bg.png
EXPORT_PATH="$BUILD_DIR"/Postgres-export
DMG_SRC_PATH="$BUILD_DIR"/Postgres
DMG_DST_PATH="$BUILD_DIR"/Postgres-$POSTGRESAPP_SHORT_VERSION-${PG_BINARIES_VERSIONS//_/-}.dmg
SIGNATURE_PATH="$BUILD_DIR"/Postgres-$POSTGRESAPP_SHORT_VERSION-${PG_BINARIES_VERSIONS//_/-}-signature.txt
APPCAST_PATH="$BUILD_DIR"/updates_$PG_BINARIES_VERSIONS.xml


mkdir -p "$LOG_DIR"
echo "Log Directory: $LOG_DIR"

env >"$LOG_DIR/env"

# notarize
echo -n "Notarizing Build... "
./notarize-build.py --username "$NOTARIZATION_USER" --password "$NOTARIZATION_PASSWORD" --notarize-dmg "$DMG_DST_PATH" --bundle-id com.postgresapp.Postgres2 --log "$LOG_DIR/notarize.log" >"$LOG_DIR/notarize.out" 2>"$LOG_DIR/notarize.err"
echo "Done"
echo -n "Stapling... "
./notarize-build.py --staple-app "$DMG_DST_PATH" --log "$LOG_DIR/staple.log" >"$LOG_DIR/staple.out" 2>"$LOG_DIR/staple.err"
echo "Done"

# sign update
echo -n "Signing... "
./sign_update "$DMG_DST_PATH" "$SPARKLE_SIGNING_KEY" >"$SIGNATURE_PATH" 2>"$LOG_DIR/sign_update.err"
echo "Done"

echo
echo "       Path: $DMG_DST_PATH"
echo "       Size:" $(stat -f %z "$DMG_DST_PATH")
echo "  Signature:" $(cat "$SIGNATURE_PATH")
echo

echo "Appcast:"
tee "$APPCAST_PATH" <<EOF
<?xml version="1.0" encoding="utf-8"?>
<rss version="2.0" xmlns:sparkle="http://www.andymatuschak.org/xml-namespaces/sparkle"  xmlns:dc="http://purl.org/dc/elements/1.1/">
  <channel>
    <title>Postgres Changelog</title>
    <link>https://postgresapp.com/sparkle/updates_$PG_BINARIES_VERSIONS.xml</link>
    <description>Most recent changes with links to updates.</description>
    <language>en</language>
	<item>
		<title>Postgres.app $POSTGRESAPP_SHORT_VERSION</title>
		<description>
			<![CDATA[
				<ul>
$(
	for v in ${PG_BINARIES_VERSIONS//_/ }
	do
		pg_version=$(grep 'PG_VERSION "[^"]*' --only-matching "$PG_BINARIES_DIR"/$v/include/postgresql/server/pg_config.h | cut -c 13-)
		postgis_version=$(grep "default_version = '[^']*"  --only-matching "$PG_BINARIES_DIR"/$v/share/postgresql/extension/postgis.control | cut -c 20-)
		echo "					<li>PostgreSQL $pg_version with PostGIS $postgis_version</li>"
	done
)
				</ul>
			]]>
		</description>
		<pubDate>$(date -R)</pubDate>
		<enclosure
		url="https://github.com/PostgresApp/PostgresApp/releases/download/v$POSTGRESAPP_SHORT_VERSION/Postgres-$POSTGRESAPP_SHORT_VERSION-${PG_BINARIES_VERSIONS//_/-}.dmg"
		sparkle:version="$POSTGRESAPP_BUILD_VERSION"
		sparkle:shortVersionString="$POSTGRESAPP_SHORT_VERSION"
		length="$(stat -f %z "$DMG_DST_PATH")"
		type="application/octet-stream"
		sparkle:dsaSignature="$(cat "$SIGNATURE_PATH")"
		/>
	</item>
  </channel>
</rss>
EOF

echo
echo
echo
