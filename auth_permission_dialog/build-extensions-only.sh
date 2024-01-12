#!/bin/zsh

# This script updates the auth_permission_dialog extension for PostgreSQL versions in Postgres.app
# It is only meant to be used when working on the auth_permission_dialog extension
# It assumes that you already have Postgres.app installed in /Applications

set -e

rm -f *.o(N) *.dylib(N) *.so(N)

cd ..

for i in 11 12 13
do
	make -C src-$i clean-auth_permission_dialog
	make -C src-$i -o "/Applications/Postgres.app/Contents/Versions/$i/bin/psql" CFLAGS="-Os -mmacosx-version-min=10.12 -arch x86_64" auth_permission_dialog
done

for i in 14 15 16
do
	make -C src-$i clean-auth_permission_dialog
	make -C src-$i -o "/Applications/Postgres.app/Contents/Versions/$i/bin/psql" auth_permission_dialog
done