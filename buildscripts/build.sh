#!/bin/bash

set -e

PROJECT_ROOT=$(dirname $(pwd))

VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$PROJECT_ROOT"/Postgres/Info.plist)
GIT_COMMIT=$(git rev-parse --short HEAD)

PROJECT_FILE="$PROJECT_ROOT"/Postgres.xcodeproj
ARCHIVE_PATH=~/Documents/Postgres-archives/Postgres-$VERSION-$GIT_COMMIT/Postgres.xcarchive
BGIMG_PATH=background-image/folder_bg.png
DMG_SRC_PATH=~/Documents/Postgres-archives/Postgres-$VERSION-$GIT_COMMIT/Postgres
DMG_DST_PATH=~/Documents/Postgres-archives/Postgres-$VERSION-$GIT_COMMIT/Postgres-$VERSION.dmg
SIGNATURE_PATH=~/Documents/Postgres-archives/Postgres-$VERSION-$GIT_COMMIT/signature.txt

# remove old builds (if exist)
#[ -e "$ARCHIVE_PATH" ] && rm -r "$ARCHIVE_PATH"
#[ -e "$DMG_SRC_PATH/Postgres.app" ] && rm -r "$DMG_SRC_PATH/Postgres.app"
#[ -e "$DMG_DST_PATH" ] && rm "$DMG_DST_PATH"

# get signing identity
SIGN_ID=$(security find-certificate -a -c "Developer ID Application" -Z | grep -o -e 'Developer ID [^"]*' | head -n 1)

# build the archive
xcodebuild archive -project "$PROJECT_FILE" -scheme Postgres -archivePath "$ARCHIVE_PATH"

# export and code sign
mkdir -p "$DMG_SRC_PATH"
xcodebuild -exportArchive -exportFormat APP -archivePath "$ARCHIVE_PATH" -exportPath "$DMG_SRC_PATH/Postgres.app" -exportSigningIdentity "$SIGN_ID"

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
"$DMG_SRC_PATH"

./sign_update "$DMG_DST_PATH" /Volumes/PostgresKey/dsa_priv.pem >"$SIGNATURE_PATH"
