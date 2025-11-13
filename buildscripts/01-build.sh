#!/bin/bash

# Call this script like this:
# POSTGRESAPP_SHORT_VERSION=2.x.x POSTGRESAPP_BUILD_VERSION=xx PG_BINARIES_VERSIONS=10_11_12 PG_BINARIES_DIR=$HOME/PostgresApp/Binaries LATEST_STABLE_PG_VERSION=12 BUILD_DIR=$HOME/PostgresApp/Build ./01-build.sh

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

if [ "x$PG_BINARIES_DIR" = x ]
then
	echo "Please set the environment variable PG_BINARIES_DIR"
	exit 1
fi

if [ "x$LATEST_STABLE_PG_VERSION" = x ]
then
	echo "Please set the environment variable LATEST_STABLE_PG_VERSION"
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
EXPORT_PATH="$BUILD_DIR"/Postgres-export
DMG_SRC_PATH="$BUILD_DIR"/Postgres
DMG_DST_PATH="$BUILD_DIR"/Postgres-$POSTGRESAPP_SHORT_VERSION-${PG_BINARIES_VERSIONS//_/-}.dmg
SIGNATURE_PATH="$BUILD_DIR"/Postgres-$POSTGRESAPP_SHORT_VERSION-${PG_BINARIES_VERSIONS//_/-}-signature.txt
APPCAST_PATH="$BUILD_DIR"/updates_$PG_BINARIES_VERSIONS.xml
DERIVED_DATA_PATH="$BUILD_DIR"/DerivedData

mkdir -p "$LOG_DIR"
echo "Log Directory: $LOG_DIR"

env >"$LOG_DIR/01-build-env.log"


# get signing identity
CODE_SIGN_IDENTITY=$(security find-certificate -a -c "Developer ID Application" -Z | grep -o -e 'Developer ID [^"]*' | head -n 1)

echo "Using Certificate \"$CODE_SIGN_IDENTITY\""

# build the archive
echo -n "Archive... "
xcodebuild archive -project "$PROJECT_FILE" -scheme Postgres -archivePath "$ARCHIVE_PATH" -derivedDataPath "$DERIVED_DATA_PATH" POSTGRESAPP_SHORT_VERSION="$POSTGRESAPP_SHORT_VERSION" POSTGRESAPP_BUILD_VERSION="$POSTGRESAPP_BUILD_VERSION" PG_BINARIES_VERSIONS="$PG_BINARIES_VERSIONS" PG_BINARIES_DIR="$PG_BINARIES_DIR" LATEST_STABLE_PG_VERSION="$LATEST_STABLE_PG_VERSION" CODE_SIGN_IDENTITY="$CODE_SIGN_IDENTITY">"$LOG_DIR/02-archive.log" 2>&1
echo "Done"

# Delete Derived Data
rm -r "$DERIVED_DATA_PATH" || echo "INFO: Deleting $DERIVED_DATA_PATH failed"

# export and code sign
echo -n "Export Archive... "
xcodebuild -exportArchive -archivePath "$ARCHIVE_PATH" -exportPath "$EXPORT_PATH" -exportOptionsPlist exportOptions.plist >"$LOG_DIR/03-exportArchive.log" 2>&1
echo "Done"

echo -n "Enabling Hardened Runtime... "

APP="$EXPORT_PATH"/Postgres.app

for VERSION in ${PG_BINARIES_VERSIONS//_/ }; do

	find "$APP"/Contents/Versions/$VERSION/bin/ -name postgres -type f -exec \
		codesign --force --timestamp --options runtime --sign "$CODE_SIGN_IDENTITY" --prefix com.postgresapp. \
			--entitlements postgres.entitlements \
			{} \; >>"$LOG_DIR/04-codesign.log" 2>&1

	find "$APP"/Contents/Versions/$VERSION/bin/ -not -name postgres -type f -exec \
		codesign --force --timestamp --options runtime  --sign "$CODE_SIGN_IDENTITY" --prefix com.postgresapp. \
			{} \; >>"$LOG_DIR/04-codesign.log" 2>&1

	find "$APP"/Contents/Versions/$VERSION/lib/postgresql/pgxs \( -name isolationtester -or -name pg_isolation_regress \) -type f -exec \
		codesign --force --timestamp --options runtime  --sign "$CODE_SIGN_IDENTITY" --prefix com.postgresapp. \
			{} \; >>"$LOG_DIR/04-codesign.log" 2>&1

	codesign --force --timestamp --options runtime --sign "$CODE_SIGN_IDENTITY" --prefix com.postgresapp. \
		"$APP"/Contents/Versions/$VERSION/lib/postgresql/pgxs/src/test/regress/pg_regress \
		"$APP"/Contents/Versions/$VERSION/lib/*.a \
		>>"$LOG_DIR/04-codesign.log" 2>&1

done

codesign --force --timestamp --options runtime --sign "$CODE_SIGN_IDENTITY" \
	"$APP"/Contents/Frameworks/Sparkle.framework/Versions/A/Resources/Autoupdate.app/Contents/MacOS/Autoupdate \
	"$APP"/Contents/Frameworks/Sparkle.framework/Versions/A/Sparkle \
	"$APP"/Contents/MacOS/PostgresMenuHelper.app \
	"$APP"/Contents/Library/LoginItems/PostgresLoginHelper.app \
	>>"$LOG_DIR/04-codesign.log" 2>&1

codesign --force --timestamp --options runtime --sign "$CODE_SIGN_IDENTITY" \
	"$APP"/Contents/MacOS/PostgresPermissionDialog \
	>>"$LOG_DIR/04-codesign.log" 2>&1

codesign --force --timestamp --options runtime --sign "$CODE_SIGN_IDENTITY" \
	--entitlements PostgresApp.entitlements \
	"$APP"/Contents/MacOS/Postgres \
	"$APP" \
	>>"$LOG_DIR/04-codesign.log" 2>&1

echo "Done"


echo -n "Creating Disk Image... "

mkdir "$DMG_SRC_PATH"
mv "$EXPORT_PATH"/Postgres.app "$DMG_SRC_PATH"
rm -r "$EXPORT_PATH" || echo "INFO: Deleting $EXPORT_PATH failed"

vendor/create-dmg-master/create-dmg \
    --window-pos 200 150 \
    --window-size 512 320 \
    --icon Postgres.app 110 150 \
    --app-drop-link 400 150 \
    --text-size 12 \
    --icon-size 128 \
    --background "$BGIMG_PATH" \
    "$DMG_DST_PATH" \
    "$DMG_SRC_PATH" >"$LOG_DIR/05-create-dmg.log" 2>&1

rm -r "$DMG_SRC_PATH" || echo "INFO: Deleting $DMG_SRC_PATH failed"

echo "Done"
