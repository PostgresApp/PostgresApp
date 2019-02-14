#!/bin/bash

set -e
set -o pipefail

PROJECT_ROOT=$(dirname $(pwd))

# get version and buildnumber
VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$PROJECT_ROOT"/Postgres/Info.plist)
BUILD_NO=$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "$PROJECT_ROOT"/Postgres/Info.plist)

PROJECT_FILE="$PROJECT_ROOT"/Postgres.xcodeproj
ARCHIVE_PATH=~/Documents/postgresapp/archives/Postgres-$VERSION-$BUILD_NO/Postgres.xcarchive
BGIMG_PATH=background-image/folder_bg.png
EXPORT_PATH=~/Documents/postgresapp/archives/Postgres-$VERSION-$BUILD_NO/Postgres-export
DMG_SRC_PATH=~/Documents/postgresapp/archives/Postgres-$VERSION-$BUILD_NO/Postgres
DMG_DST_PATH=~/Documents/postgresapp/archives/Postgres-$VERSION-$BUILD_NO/Postgres-$VERSION.dmg
SIGNATURE_PATH=~/Documents/postgresapp/archives/Postgres-$VERSION-$BUILD_NO/signature.txt

# get signing identity
SIGN_ID=$(security find-certificate -a -c "Developer ID Application" -Z | grep -o -e 'Developer ID [^"]*' | head -n 1)

# build the archive
xcodebuild archive -project "$PROJECT_FILE" -scheme Postgres -archivePath "$ARCHIVE_PATH"

# export and code sign
xcodebuild -exportArchive -archivePath "$ARCHIVE_PATH" -exportPath "$EXPORT_PATH" -exportOptionsPlist exportOptions.plist
mkdir "$DMG_SRC_PATH"
mv "$EXPORT_PATH"/Postgres.app "$DMG_SRC_PATH"

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

# sign update
./sign_update "$DMG_DST_PATH" ~/Documents/postgresapp/key/dsa_priv.pem >"$SIGNATURE_PATH"
