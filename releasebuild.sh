#!/bin/bash

# Remove existing Postgres.app in Applications folder (since we need that path for building)

rm -Rf /Applications/Postgres.app/Contents/Versions/9.6


# Build PostgreSQL, PostGIS, etc.

cd src

make clean

time caffeinate make

say "I'm finished building Postgres app!"
