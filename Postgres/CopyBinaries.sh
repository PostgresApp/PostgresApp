#!/bin/bash

#  CopyBinaries.sh
#  Postgres
#
#  Created by Jakob Egger on 15/12/16.
#

ORIG_INSTALL_ROOT="/Applications/Postgres.app/Contents/Versions/${POSTGRES_MAJOR_VERSION}"
EXECUTABLE_TARGET_DIR="$BUILT_PRODUCTS_DIR/$CONTENTS_FOLDER_PATH/Versions/${POSTGRES_MAJOR_VERSION}"

# copy binaries
cd "${ORIG_INSTALL_ROOT}/bin/"
mkdir -p "$EXECUTABLE_TARGET_DIR/bin/"
# copy postgresql binaries
cp clusterdb createdb createlang createuser dropdb droplang dropuser ecpg initdb oid2name pg* postgres postmaster psql reindexdb vacuumdb vacuumlo "$EXECUTABLE_TARGET_DIR/bin/"
#copy proj binaries
cp cs2cs geod invgeod invproj nad2bin proj "$EXECUTABLE_TARGET_DIR/bin/"
#copy gdal binaries
cp gdal* nearblack ogr2ogr ogrinfo ogrtindex testepsg "$EXECUTABLE_TARGET_DIR/bin/"
#copy postgis binaries
cp raster2pgsql shp2pgsql "$EXECUTABLE_TARGET_DIR/bin/"

# copy all dynamic libraries
cd "${ORIG_INSTALL_ROOT}/lib/"
mkdir -p "$EXECUTABLE_TARGET_DIR/lib/"
cp -af *.dylib "$EXECUTABLE_TARGET_DIR/lib/"
cp -afR postgresql "$EXECUTABLE_TARGET_DIR/lib/"

# copy static libraries where a dynamic one doesn't exist
for file in *.a
do
    if  [ ! -f "${file%.*}.dylib" ]
    then
        cp -af $file "$EXECUTABLE_TARGET_DIR/lib/"
    fi
done

#copy include, share
rm -f "$EXECUTABLE_TARGET_DIR/include/json"
cp -afR "${ORIG_INSTALL_ROOT}/include" "${ORIG_INSTALL_ROOT}/share" "$EXECUTABLE_TARGET_DIR/"

#create symbolic link
cd "$BUILT_PRODUCTS_DIR/$CONTENTS_FOLDER_PATH/Versions/"
ln -sfh ${POSTGRES_MAJOR_VERSION} latest
