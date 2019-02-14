#!/bin/bash

set -e
set -o pipefail

export NSUnbufferedIO=YES
export PYTHONUNBUFFERED=1

trap 'if [[ $? -ne 0 ]]; then echo "Error"; echo "Check Log For Details"; fi' EXIT


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

if [ x$SPARKLE_SIGNING_KEY = x ]
then
	echo "Please set SPARKLE_SIGNING_KEY to the path of the DSA key used for signing sparkle updates."
	exit 1
fi


PROJECT_ROOT=$(dirname $(pwd))
PROJECT_FILE="$PROJECT_ROOT"/Postgres.xcodeproj

BUILD_DIR="$(dirname $(dirname $(pwd)))/archives/Postgres-$POSTGRESAPP_BUILD_VERSION-v$POSTGRESAPP_SHORT_VERSION-${PG_BINARIES_VERSIONS//_/-}"
LOG_DIR="$BUILD_DIR/log"
ARCHIVE_PATH="$BUILD_DIR"/Postgres.xcarchive
BGIMG_PATH=background-image/folder_bg.png
EXPORT_PATH="$BUILD_DIR"/Postgres-export
DMG_SRC_PATH="$BUILD_DIR"/Postgres
DMG_DST_PATH="$BUILD_DIR"/Postgres-$POSTGRESAPP_SHORT_VERSION-${PG_BINARIES_VERSIONS//_/-}.dmg
SIGNATURE_PATH="$BUILD_DIR"/Postgres-$POSTGRESAPP_SHORT_VERSION-${PG_BINARIES_VERSIONS//_/-}-signature.txt


mkdir -p "$LOG_DIR"
echo "Log Directory: $LOG_DIR"

env >"$LOG_DIR/env"


# get signing identity
CODE_SIGN_IDENTITY=$(security find-certificate -a -c "Developer ID Application" -Z | grep -o -e 'Developer ID [^"]*' | head -n 1)

echo "Using Certificate \"$CODE_SIGN_IDENTITY\""

# build the archive
echo -n "Archive... "
xcodebuild archive -project "$PROJECT_FILE" -scheme Postgres -archivePath "$ARCHIVE_PATH" POSTGRESAPP_SHORT_VERSION="$POSTGRESAPP_SHORT_VERSION" POSTGRESAPP_BUILD_VERSION="$POSTGRESAPP_BUILD_VERSION" PG_BINARIES_VERSIONS="$PG_BINARIES_VERSIONS" PG_BINARIES_DIR="$PG_BINARIES_DIR" LATEST_STABLE_PG_VERSION="$LATEST_STABLE_PG_VERSION" CODE_SIGN_IDENTITY="$CODE_SIGN_IDENTITY">"$LOG_DIR/archive.out" 2>"$LOG_DIR/archive.err"
echo "Done"

# export and code sign
echo -n "Export Archive... "
xcodebuild -exportArchive -archivePath "$ARCHIVE_PATH" -exportPath "$EXPORT_PATH" -exportOptionsPlist exportOptions.plist >"$LOG_DIR/exportArchive.out" 2>"$LOG_DIR/exportArchive.err"
echo "Done"

mkdir "$DMG_SRC_PATH"
mv "$EXPORT_PATH"/Postgres.app "$DMG_SRC_PATH"

echo -n "Creating Disk Image... "
# create dmg
vendor/create-dmg-master/create-dmg \
    --window-pos 200 150 \
    --window-size 512 320 \
    --icon Postgres.app 110 150 \
    --app-drop-link 400 150 \
    --text-size 12 \
    --icon-size 128 \
    --background "$BGIMG_PATH" \
    "$DMG_DST_PATH" \
    "$DMG_SRC_PATH" >"$LOG_DIR/create-dmg.out" 2>"$LOG_DIR/create-dmg.err"
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
