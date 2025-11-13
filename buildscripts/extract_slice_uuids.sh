#!/bin/zsh
# extracts the slice uuids of the executables in a postgres.app bundle 
# and dumps them in a format suitable for import to a database table
# 21002FD1-D193-3057-B085-6D4634BDEAB5	arm64	18/postgres	319	2.8.3	2020-01-01
# 9B9651E6-9839-3305-AB1E-12DE1CBAF2A0	x86_64	PostgresMenuHelper	345	2.9	2025-11-13

#set -e
set -o pipefail
if [ "$#" -le 1 ]; then
  echo "Usage: $0 path_to_app release_date"
  exit 1
fi

APPPATH=$1
VERSION=$(plutil -extract CFBundleShortVersionString raw "$APPPATH"/Contents/Info.plist)
BUILD=$(plutil -extract CFBundleVersion raw "$APPPATH"/Contents/Info.plist)
RELEASE_DATE=$2

find "$APPPATH" \( -name Postgres\* -or -name postgres -or -name psql \) \
  -type f -perm +111 \
  -exec dwarfdump -u {} \; \
  | sed -E "s/^UUID: ([A-F0-9-]+) \(([a-z0-9_]+)\) (.+\/Versions\/(.+\/)bin\/(.+)|.+\/(.+))$/\1\t\2\t\4\5\6\t$BUILD\t$VERSION\t$RELEASE_DATE/"
