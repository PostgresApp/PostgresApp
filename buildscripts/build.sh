#!/bin/bash

set -e

PROJECT_FILE=~/Developer/Repositories/PostgresApp/Postgres.xcodeproj
ARCHIVE_PATH=archives/postgres.xcarchive
BGIMG_PATH=background-image/folder_bg.png
DMG_SRC_PATH=Postgres
DMG_DST_PATH=~/Desktop/Postgres.dmg

# remove old builds (if exist)
#[ -e "$ARCHIVE_PATH" ] && rm -r "$ARCHIVE_PATH"
#[ -e "$DMG_SRC_PATH/Postgres.app" ] && rm -r "$DMG_SRC_PATH/Postgres.app"
[ -e "$DMG_DST_PATH" ] && rm "$DMG_DST_PATH"

# get signing identity
SIGN_ID=$(security find-certificate -a -c "Developer ID Application" -Z | grep -o -e 'Developer ID [^"]*' | head -n 1)

# build the archive
#xcodebuild archive -project "$PROJECT_FILE" -scheme Postgres -archivePath "$ARCHIVE_PATH"

# export and code sign
#xcodebuild -exportArchive -exportFormat APP -archivePath "$ARCHIVE_PATH" -exportPath "$DMG_SRC_PATH/Postgres.app" -exportSigningIdentity "$SIGN_ID"

# create dmg
vendor/create-dmg-master/create-dmg \
--window-pos 200 120 \
--window-size 600 300 \
--icon Postgres.app 200 100 \
--app-drop-link 400 100 \
--text-size 12 \
--icon-size 64 \
--background "$BGIMG_PATH" \
"$DMG_DST_PATH" \
"$DMG_SRC_PATH"
