#!/bin/bash

#  CopyBinariesScript.sh
#  Postgres
#
#  Created by Jakob Egger on 31/08/2016.
#  Copyright © 2016 postgresapp. All rights reserved.

SOURCE_VERSIONS_DIR="/Applications/Postgres.app/Contents/Versions"
TARGET_VERSIONS_DIR="$BUILT_PRODUCTS_DIR/$CONTENTS_FOLDER_PATH/Versions"

cd "$SOURCE_VERSIONS_DIR"

for VERSION in [123456789]*
do
	if [ ! -e "${TARGET_VERSIONS_DIR}/${VERSION}" ]
	then
		# copy binaries
		cd "${SOURCE_VERSIONS_DIR}/${VERSION}/bin/"
		mkdir -p "${TARGET_VERSIONS_DIR}/${VERSION}/bin/"
		# copy postgresql binaries
		cp clusterdb createdb createuser dropdb dropuser ecpg initdb oid2name pg* postgres postmaster psql reindexdb vacuumdb vacuumlo "${TARGET_VERSIONS_DIR}/${VERSION}/bin/"
        if [ -e createlang ]
        then
            # removed in PostgreSQL 10
            cp createlang droplang "${TARGET_VERSIONS_DIR}/${VERSION}/bin/"
        fi
		# copy proj binaries
		cp cs2cs geod invgeod invproj nad2bin proj "${TARGET_VERSIONS_DIR}/${VERSION}/bin/"
		# copy gdal binaries
		cp gdal* nearblack ogr2ogr ogrinfo ogrtindex testepsg "${TARGET_VERSIONS_DIR}/${VERSION}/bin/"
		# copy postgis binaries
		cp raster2pgsql shp2pgsql "${TARGET_VERSIONS_DIR}/${VERSION}/bin/"

		# copy all dynamic libraries
		cd "${SOURCE_VERSIONS_DIR}/${VERSION}/lib/"
		mkdir -p "${TARGET_VERSIONS_DIR}/${VERSION}/lib/"
		cp -af *.dylib "${TARGET_VERSIONS_DIR}/${VERSION}/lib/"
		cp -afR postgresql "${TARGET_VERSIONS_DIR}/${VERSION}/lib/"
		
		# copy static libraries where a dynamic one doesn't exist
		for file in *.a
		do
			if  [ ! -f "${file%.*}.dylib" ]
			then
				cp -af $file "${TARGET_VERSIONS_DIR}/${VERSION}/lib/"
			fi
		done

		# copy include, share
		rm -f "${TARGET_VERSIONS_DIR}/${VERSION}/include/json"
		cp -afR "${SOURCE_VERSIONS_DIR}/${VERSION}/include" "${SOURCE_VERSIONS_DIR}/${VERSION}/share" "${TARGET_VERSIONS_DIR}/${VERSION}/"
	fi
done

# create symbolic link
cd "$BUILT_PRODUCTS_DIR/$CONTENTS_FOLDER_PATH/Versions/"
ln -sfh ${LATEST_STABLE_PG_VERSION} latest
