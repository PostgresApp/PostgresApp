#!/bin/bash

# Before calling this script, make sure you have stored App Store Connect API credentials in the keychain
# xcrun notarytool store-credentials postgresapp
# Then you can call this script like this:
# POSTGRESAPP_SHORT_VERSION=2.x.x POSTGRESAPP_BUILD_VERSION=xx PG_BINARIES_VERSIONS=10_11_12 LATEST_STABLE_PG_VERSION=12  SPARKLE_SIGNING_KEY=example.pem ./02-notarize.sh

set -e
set -o pipefail

export NSUnbufferedIO=YES
export PYTHONUNBUFFERED=1

trap 'ERROR_COMMAND=$BASH_COMMAND' ERR
trap 'status=$?;
	if [[ $status -ne 0 ]]; then
		echo "ERROR"
		echo "	$ERROR_COMMAND"
		echo "	Exit Code $status"
		echo "	Check Log For Details"
	fi
	exit $status' EXIT

if [ "x$POSTGRESAPP_SHORT_VERSION" = x ]
then
	echo "Please set the environment variable POSTGRESAPP_SHORT_VERSION"
	exit 1
fi

if [ "x$POSTGRESAPP_BUILD_VERSION" = x ]
then
	echo "Please set the environment variable POSTGRESAPP_BUILD_VERSION"
	exit 1
fi

if [ "x$PG_BINARIES_VERSIONS" = x ]
then
	echo "Please set the environment variable PG_BINARIES_VERSIONS"
	exit 1
fi

if [ "x$LATEST_STABLE_PG_VERSION" = x ]
then
	echo "Please set the environment variable LATEST_STABLE_PG_VERSION"
	exit 1
fi

if [ "x$SPARKLE_SIGNING_KEY" = x ]
then
	echo "Please set SPARKLE_SIGNING_KEY to the path of the DSA key used for signing sparkle updates."
	exit 1
fi

if [ "x$BUILD_DIR" = x ]
then
	echo "Please set BUILD_DIR"
	exit 1
fi



PROJECT_ROOT=$(dirname $(pwd))
PROJECT_FILE="$PROJECT_ROOT"/Postgres.xcodeproj

LOG_DIR="$BUILD_DIR/log"
ARCHIVE_PATH="$BUILD_DIR"/Postgres.xcarchive
BGIMG_PATH=background-image/folder_bg.png
DMG_DST_PATH="$BUILD_DIR"/Postgres-$POSTGRESAPP_SHORT_VERSION-${PG_BINARIES_VERSIONS//_/-}.dmg
SIGNATURE_PATH="$BUILD_DIR"/Postgres-$POSTGRESAPP_SHORT_VERSION-${PG_BINARIES_VERSIONS//_/-}-signature.txt
APPCAST_PATH="$BUILD_DIR"/updates_$PG_BINARIES_VERSIONS.xml

mkdir -p "$LOG_DIR"
echo "Log Directory: $LOG_DIR"

env >"$LOG_DIR/06-notarize-env.log"

# Read the minumum macOS version from the xcarchive
echo -n "Reading LSMinimumSystemVersion from Archive... "
MACOSX_DEPLOYMENT_TARGET=$(plutil -extract LSMinimumSystemVersion raw "$ARCHIVE_PATH"/Products/Applications/Postgres.app/Contents/Info.plist)
echo "Done"

# notarize
echo -n "Notarizing Build... "
xcrun notarytool submit "$DMG_DST_PATH" --wait --keychain-profile postgresapp >"$LOG_DIR/07-notarize.log" 2>&1
echo "Done"
echo -n "Stapling... "
xcrun stapler staple "$DMG_DST_PATH" >"$LOG_DIR/08-staple.log" 2>&1
echo "Done"

# sign update
echo -n "Signing... "
./sign_update "$DMG_DST_PATH" "$SPARKLE_SIGNING_KEY" >"$SIGNATURE_PATH" 2>"$LOG_DIR/09-sign_update_error.log"
echo "Done"

echo -n "Generating Appcast... "
cat >"$APPCAST_PATH" <<EOF
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
		pg_version=$(grep 'PACKAGE_VERSION "[^"]*' --only-matching "$ARCHIVE_PATH"/Products/Applications/Postgres.app/Contents/Versions/$v/include/postgresql/server/pg_config.h | cut -c 18-)
		postgis_version=$(grep "default_version = '[^']*"  --only-matching "$ARCHIVE_PATH"/Products/Applications/Postgres.app/Contents/Versions/$v/share/postgresql/extension/postgis.control 2> >(test $IGNORE_MISSING_BINARIES || cat >&2) | cut -c 20-)
		[ -z $postgis_version ] || echo "					<li>PostgreSQL $pg_version with PostGIS $postgis_version</li>"
		! [ -z $postgis_version ] || echo "					<li>PostgreSQL $pg_version without PostGIS</li>"
	done
)
				</ul>
				<p>You can find more info on the <a href="https://github.com/PostgresApp/PostgresApp/releases">Github Releases Page</a>.</p>
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
		<sparkle:minimumSystemVersion>$MACOSX_DEPLOYMENT_TARGET</sparkle:minimumSystemVersion>
	</item>
  </channel>
</rss>
EOF
echo "Done"

echo
echo "       Path: $DMG_DST_PATH"
echo "       Size:" $(stat -f %z "$DMG_DST_PATH")
echo "  Signature:" $(cat "$SIGNATURE_PATH")
echo "    Appcast:" "$APPCAST_PATH"
echo
echo
echo
