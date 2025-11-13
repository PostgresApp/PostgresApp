#!/bin/bash

# Before calling this script, make sure you have stored App Store Connect API credentials in the keychain
# xcrun notarytool store-credentials postgresapp
# Then you can call this script like this:
# POSTGRESAPP_SHORT_VERSION=2.x.x PG_BINARIES_VERSIONS=10_11_12 BUILD_DIR=$HOME/PostgresApp/Build ./02-notarize.sh

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

if [ "x$PG_BINARIES_VERSIONS" = x ]
then
	echo "Please set the environment variable PG_BINARIES_VERSIONS"
	exit 1
fi

if [ "x$BUILD_DIR" = x ]
then
	echo "Please set BUILD_DIR"
	exit 1
fi


LOG_DIR="$BUILD_DIR/log"
DMG_DST_PATH="$BUILD_DIR"/Postgres-$POSTGRESAPP_SHORT_VERSION-${PG_BINARIES_VERSIONS//_/-}.dmg

mkdir -p "$LOG_DIR"
echo "Log Directory: $LOG_DIR"

env >"$LOG_DIR/06-notarize-env.log"

# notarize
echo -n "Notarizing Build... "
xcrun notarytool submit "$DMG_DST_PATH" --wait --keychain-profile postgresapp >"$LOG_DIR/07-notarize.log" 2>&1
echo "Done"
echo -n "Stapling... "
xcrun stapler staple "$DMG_DST_PATH" >"$LOG_DIR/08-staple.log" 2>&1
echo "Done"
