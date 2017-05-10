#!/bin/bash

set -e

PROJECT_ROOT=$(dirname $(pwd))

# get version, buildnumber and increment buildnumber
VERSION=$(/usr/libexec/PlistBuddy -c "Print :CFBundleShortVersionString" "$PROJECT_ROOT"/Postgres/Info.plist)
BUILD_NO_NEW=$(($(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "$PROJECT_ROOT"/Postgres/Info.plist)+1))

# set incremented build number
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $BUILD_NO_NEW" "$PROJECT_ROOT"/Postgres/Info.plist

PROJECT_FILE="$PROJECT_ROOT"/Postgres.xcodeproj
ARCHIVE_PATH=~/Documents/Developer/Postgres-archives/Postgres-$VERSION-$BUILD_NO_NEW/Postgres.xcarchive
BGIMG_PATH=background-image/folder_bg.png
DMG_SRC_PATH=~/Documents/Developer/Postgres-archives/Postgres-$VERSION-$BUILD_NO_NEW/Postgres
DMG_DST_PATH=~/Documents/Developer/Postgres-archives/Postgres-$VERSION-$BUILD_NO_NEW/Postgres-$VERSION.dmg
SIGNATURE_PATH=~/Documents/Developer/Postgres-archives/Postgres-$VERSION-$BUILD_NO_NEW/signature.txt

# get signing identity
SIGN_ID=$(security find-certificate -a -c "Developer ID Application" -Z | grep -o -e 'Developer ID [^"]*' | head -n 1)

# build the archive
xcodebuild archive -project "$PROJECT_FILE" -scheme Postgres -archivePath "$ARCHIVE_PATH"

# export and code sign
mkdir -p "$DMG_SRC_PATH"
xcodebuild -exportArchive -archivePath "$ARCHIVE_PATH" -exportPath "$DMG_SRC_PATH" -exportOptionsPlist exportOptions.plist

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
./sign_update "$DMG_DST_PATH" /Volumes/PostgresKey/dsa_priv.pem >"$SIGNATURE_PATH"
